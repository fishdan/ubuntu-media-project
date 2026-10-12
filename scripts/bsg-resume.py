#!/usr/bin/env python3
"""Track VLC's BSG playback and launch the watch-order playlist from that point."""

import argparse
import copy
import dbus
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time
import xml.etree.ElementTree as ET


XSPF = "http://xspf.org/ns/0/"
VLC = "http://www.videolan.org/vlc/playlist/0"
ET.register_namespace("", XSPF)
ET.register_namespace("vlc", VLC)
DATA = Path.home() / ".local/share/ubuntu-media-project/Battlestar Galactica.xspf"
STATE = Path.home() / ".local/state/ubuntu-media-project/bsg-playback.json"
RESUME = Path.home() / ".cache/ubuntu-media-project/bsg-resume.xspf"


def write_atomic(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        os.fchmod(fd, 0o600)
        with os.fdopen(fd, "wb") as stream:
            stream.write(data)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def read_tracks(playlist):
    root = ET.parse(playlist).getroot()
    track_list = root.find(f"{{{XSPF}}}trackList")
    if track_list is None:
        raise ValueError(f"No track list in {playlist}")
    tracks = track_list.findall(f"{{{XSPF}}}track")
    uris = [track.findtext(f"{{{XSPF}}}location") for track in tracks]
    if not uris or any(not uri for uri in uris) or len(uris) != len(set(uris)):
        raise ValueError(f"Missing or duplicate tracks in {playlist}")
    return root, tracks, uris


def read_state(path):
    try:
        value = json.loads(path.read_text())
        if isinstance(value["uri"], str) and isinstance(value["seconds"], (int, float)):
            return value
    except (FileNotFoundError, KeyError, ValueError, TypeError):
        pass
    return None


def save_state(path, uri, seconds, length=None):
    value = {"uri": uri, "seconds": max(0, int(seconds))}
    if length is not None:
        value["length"] = max(0, int(length))
    write_atomic(path, (json.dumps(value, indent=2) + "\n").encode())


def resume_index(state, uris):
    if not state or state["uri"] not in uris:
        return 0, 0
    index = uris.index(state["uri"])
    seconds = max(0, int(state["seconds"]))
    length = state.get("length")
    if length and length >= 30 and seconds >= length - 5 and index + 1 < len(uris):
        return index + 1, 0
    return index, seconds


def resume_playlist(root, tracks, index, seconds):
    result = copy.deepcopy(root)
    track_list = result.find(f"{{{XSPF}}}trackList")
    track_list.clear()
    for track in tracks[index:]:
        track_list.append(copy.deepcopy(track))
    if seconds >= 5:
        first = track_list[0]
        extension = ET.SubElement(first, f"{{{XSPF}}}extension", application=VLC)
        ET.SubElement(extension, f"{{{VLC}}}option").text = f"start-time={seconds}"
    ET.indent(result, space="  ")
    return ET.tostring(result, encoding="utf-8", xml_declaration=True) + b"\n"


def vlc_players(bus):
    for name in bus.list_names():
        if not str(name).startswith("org.mpris.MediaPlayer2.vlc"):
            continue
        try:
            obj = bus.get_object(name, "/org/mpris/MediaPlayer2")
            props = dbus.Interface(obj, "org.freedesktop.DBus.Properties")
            player = "org.mpris.MediaPlayer2.Player"
            metadata = props.Get(player, "Metadata")
            uri = str(metadata.get("xesam:url", ""))
            if not uri:
                continue
            status = str(props.Get(player, "PlaybackStatus"))
            seconds = int(props.Get(player, "Position")) // 1_000_000
            length = int(metadata.get("mpris:length", 0)) // 1_000_000
            yield name, obj, uri, status, seconds, length
        except dbus.DBusException:
            # VLC may disappear between listing and querying a bus name.
            continue


def watch(playlist, state_path):
    bus = dbus.SessionBus()
    last = read_state(state_path)
    last_write = 0.0
    recent = None
    zero_since = None
    while True:
        try:
            _, _, uris = read_tracks(playlist)
            candidates = [p for p in vlc_players(bus) if p[2] in uris and p[3] in ("Playing", "Paused")]
            if candidates:
                # A playing instance wins over an older paused VLC window.
                current = next((p for p in candidates if p[3] == "Playing"), candidates[0])
                _, _, uri, status, seconds, length = current
                now = time.monotonic()
                changed = not last or uri != last["uri"]
                recent = (uri, seconds, length)
                # VLC briefly reports zero before applying the playlist's start-time.
                if not changed and seconds == 0 and last["seconds"] >= 5:
                    zero_since = zero_since or now
                else:
                    zero_since = None
                settling = zero_since is not None and now - zero_since < 10
                if not settling and (changed or status == "Paused" or now - last_write >= 10):
                    if changed or not last or seconds != last["seconds"]:
                        save_state(state_path, uri, seconds, length)
                        last = {"uri": uri, "seconds": seconds, "length": length}
                        last_write = now
            elif recent is not None:
                # Flush the last sample when VLC closes; normal writes are throttled.
                uri, seconds, length = recent
                if not last or uri != last["uri"] or seconds != last["seconds"]:
                    save_state(state_path, uri, seconds, length)
                    last = {"uri": uri, "seconds": seconds, "length": length}
                recent = None
        except (OSError, ValueError) as error:
            print(f"BSG tracker: {error}", file=sys.stderr, flush=True)
        time.sleep(2)


def launch(playlist, state_path, output):
    try:
        root, tracks, uris = read_tracks(playlist)
    except (OSError, ET.ParseError, ValueError) as error:
        raise RuntimeError(f"Playlist unavailable: {error}") from error
    try:
        bus = dbus.SessionBus()
    except dbus.DBusException:
        bus = None
    if bus is not None:
        for _, obj, uri, status, _, _ in vlc_players(bus):
            if uri in uris and status in ("Playing", "Paused"):
                try:
                    dbus.Interface(obj, "org.mpris.MediaPlayer2").Raise()
                    return
                except dbus.DBusException:
                    break
    index, seconds = resume_index(read_state(state_path), uris)
    write_atomic(output, resume_playlist(root, tracks, index, seconds))
    subprocess.Popen(["vlc", "--no-one-instance", "--no-random", "--no-loop",
                      "--no-repeat", "--qt-continue=0", str(output)],
                     stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                     stderr=subprocess.DEVNULL, start_new_session=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("launch", "watch", "status", "reset"))
    parser.add_argument("--playlist", type=Path, default=DATA)
    parser.add_argument("--state", type=Path, default=STATE)
    parser.add_argument("--output", type=Path, default=RESUME)
    args = parser.parse_args()
    if args.command == "watch":
        watch(args.playlist, args.state)
    elif args.command == "launch":
        launch(args.playlist, args.state, args.output)
    elif args.command == "reset":
        args.state.unlink(missing_ok=True)
    else:
        _, _, uris = read_tracks(args.playlist)
        index, seconds = resume_index(read_state(args.state), uris)
        print(f"{index + 1}/{len(uris)}: {uris[index]} at {seconds // 60}:{seconds % 60:02}")


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, ValueError) as error:
        print(f"BSG resume: {error}", file=sys.stderr)
        sys.exit(1)
