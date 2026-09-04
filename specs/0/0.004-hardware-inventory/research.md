# Research: Hardware Inventory

## Decision: Collect with standard read-only Linux interfaces

Use `/proc`, `/sys`, util-linux, pciutils, usbutils, NetworkManager, BlueZ, PipeWire, and vendor tools already present. These sources describe the live machine without changing its configuration.

## Decision: Separate raw collection from reviewed documentation

The script prints a point-in-time report for diagnosis. `docs/hardware.md` records stable, reviewed conclusions so later features do not depend on a large opaque command dump.

## Decision: Exclude unique identifiers by default

Serial numbers, MAC addresses, filesystem UUIDs, IP addresses, and credentials are unnecessary for hardware selection and create avoidable privacy or security exposure. The collection commands select fields that omit them.

## Decision: Record driver bindings and uncertainty

PCI identity alone is insufficient for later graphics and networking work. Record the active kernel driver where available, and label capabilities such as Bluetooth or HDMI audio as detected rather than accepted until their dedicated feature tests occur.
