# HP ENVY Hardware Inventory

**Observed**: 2026-09-04

**Host**: HP ENVY Desktop 795-00xx (`orpheus`)

**Operating system**: Ubuntu 26.04.1 LTS

**Kernel**: Linux 7.0.0-31-generic

This inventory records hardware detected on the live appliance. Detection does not imply that later projector, receiver, Bluetooth-controller, or media-playback acceptance tests have passed.

## System and firmware

| Component | Observed value |
| --- | --- |
| Manufacturer | HP |
| Product | HP ENVY Desktop 795-00xx |
| Firmware | AMI F.41 |

Machine serial numbers and other unique identifiers are intentionally omitted.

## CPU and memory

| Component | Observed value |
| --- | --- |
| CPU | Intel Core i7-8700 at 3.20 GHz |
| Topology | 1 socket, 6 physical cores, 2 threads per core, 12 logical CPUs |
| Architecture | x86_64 |
| OS-visible memory | 14 GiB |
| Swap | 4 GiB |

The auction listing described 16 GB of installed RAM. Linux currently exposes 14 GiB as usable memory; DIMM layout and firmware-reserved capacity have not yet been inspected.

## Storage

| Device | Capacity | Type | Transport | Model |
| --- | ---: | --- | --- | --- |
| `sda` | 238.5 GiB | Non-rotational SSD | SATA | SanDisk SD9SN8W-256G-1006 |
| `sr0` | Optical drive | DVD writer | SATA | HP PLDS DVDRW DU8AESH |

The primary drive is an SSD, not a rotational hard disk. Health and endurance are outside this inventory and should be checked before relying on the original drive for irreplaceable data.

## Graphics

| Component | Observed value |
| --- | --- |
| GPU | NVIDIA GP106, GeForce GTX 1060 3GB (`10de:1c02`) |
| Active graphics driver | Proprietary `nvidia` kernel driver |
| NVIDIA driver version | 580.173.02 |
| Video memory | 3072 MiB |
| GPU audio | NVIDIA GP106 High Definition Audio Controller (`10de:10f1`) using `snd_hda_intel` |

The GPU and driver are detected and active. HDMI video, receiver compatibility, projector modes, hot-plug recovery, and HDMI audio playback remain acceptance work for Spec 005.

## Networking and Bluetooth

| Function | Hardware | Interface | Active driver | Current state |
| --- | --- | --- | --- | --- |
| Wi-Fi | Realtek RTL8822BE 802.11ac 2x2 | `wlp2s0` | `rtw88_8822be` | Connected |
| Ethernet | Realtek RTL8111/8168/8211/8411 Gigabit Ethernet | `enp3s0` | `r8169` | No physical link |
| Bluetooth | Realtek Bluetooth 4.2 adapter (`0bda:b00b`) | USB | Kernel/BlueZ stack | Controller detected |

The PCI subsystem identifies the wireless card as an RTL8822BE Wi-Fi + Bluetooth 4.2 combo adapter. Bluetooth presence is confirmed, but pairing, range, reconnect-after-boot, and DualSense behavior remain for Spec 008. Ethernet hardware and its driver are present; link-level validation still requires a cable.

## USB

Detected USB devices at inventory time:

- Linux Foundation USB 2.0 and USB 3.0 root hubs
- Genesys Logic USB 2.0 hub (`05e3:0610`)
- Genesys Logic GL3523 USB 3.0 hub (`05e3:0620`)
- Realtek Bluetooth 4.2 adapter (`0bda:b00b`)

No DualSense controller or other removable USB peripheral was attached during capture.

## Audio

Two ALSA-backed controllers are visible to PipeWire:

- NVIDIA GP106 High Definition Audio Controller
- Intel Cannon Lake PCH cAVS built-in audio using `snd_hda_intel`

At capture time, PipeWire exposed only `Dummy Output`; no usable sink or source was active. This is expected to require investigation with the receiver/projector connection in Spec 005 and is not evidence that HDMI audio works.

## Evidence and privacy

The reviewed evidence comes from `scripts/hardware-report.sh`, `lscpu`, `free`, `lsblk`, `lspci`, `lsusb`, `nmcli`, `bluetoothctl`, `wpctl`, and `nvidia-smi`. The tracked inventory excludes serial numbers, MAC addresses, IP addresses, filesystem UUIDs, runtime cookies, credentials, and raw connection profiles.
