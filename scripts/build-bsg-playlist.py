#!/usr/bin/env python3
"""Build the owner's VLC watch-order playlist from the read-only BSG share."""

import argparse
import os
from pathlib import Path
import re
import tempfile
import xml.etree.ElementTree as ET


DEFAULT_SOURCE = Path("/media_remote/BattleStarGalactica")
DEFAULT_OUTPUT = Path.home() / "Desktop" / "Battlestar Galactica.xspf"
EPISODE = re.compile(r"S(\d{2})E(\d{2})", re.IGNORECASE)
XSPF = "http://xspf.org/ns/0/"
ET.register_namespace("", XSPF)


def watch_key(path, source):
    relative = path.relative_to(source)
    folder = relative.parts[0]
    match = EPISODE.search(path.name)

    if folder == "Featurettes":
        return (16, relative.as_posix().casefold())
    if not match:
        raise ValueError(f"Unexpected video outside Featurettes: {relative}")

    season, episode = map(int, match.groups())
    if season == 0:
        special_positions = {
            1: 0, 2: 0,                  # Miniseries
            4: 4,                       # Razor, episodes 4–5 in one file
            22: 11,                     # The Plan
            40: 13,                     # Blood & Chrome
            8: 14,                      # The Lowdown, after the narrative
        }
        if 33 <= episode <= 39:       # Razor minisodes
            group = 3
        elif 23 <= episode <= 32:     # The Resistance
            group = 6
        elif 10 <= episode <= 19:     # Face of the Enemy
            group = 9
        else:
            group = special_positions.get(episode)
            if group is None:
                raise ValueError(f"Unplaced special: {relative}")
        return (group, episode, relative.as_posix().casefold())

    if season == 1:
        group = 1
    elif season == 2:
        group = 2 if episode <= 17 else 5
    elif season == 3:
        group = 7
    elif season == 4:
        group = 8 if episode <= 11 else 10 if episode <= 15 else 12
    else:
        raise ValueError(f"Unexpected season: {relative}")
    return (group, episode, relative.as_posix().casefold())


def build_playlist(source):
    files = sorted(source.rglob("*.mkv"), key=lambda path: watch_key(path, source))
    if not files:
        raise ValueError(f"No MKV videos found in {source}")

    root = ET.Element(f"{{{XSPF}}}playlist", version="1")
    ET.SubElement(root, f"{{{XSPF}}}title").text = "Battlestar Galactica — Watch Order"
    track_list = ET.SubElement(root, f"{{{XSPF}}}trackList")
    for path in files:
        track = ET.SubElement(track_list, f"{{{XSPF}}}track")
        ET.SubElement(track, f"{{{XSPF}}}location").text = path.absolute().as_uri()
        ET.SubElement(track, f"{{{XSPF}}}title").text = path.stem
    ET.indent(root, space="  ")
    return ET.tostring(root, encoding="utf-8", xml_declaration=True) + b"\n", len(files)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()

    if not args.source.is_dir():
        parser.error(f"Media folder is unavailable: {args.source}")
    if not args.output.parent.is_dir():
        parser.error(f"Output folder is unavailable: {args.output.parent}")

    data, count = build_playlist(args.source)
    if args.output.exists() and args.output.read_bytes() == data:
        print(f"Unchanged: {args.output} ({count} videos)")
        return

    fd, temporary = tempfile.mkstemp(prefix=".bsg-playlist-", dir=args.output.parent)
    try:
        with os.fdopen(fd, "wb") as stream:
            stream.write(data)
        os.replace(temporary, args.output)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)
    print(f"Wrote: {args.output} ({count} videos)")


if __name__ == "__main__":
    main()
