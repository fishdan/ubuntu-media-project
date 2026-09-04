# Data Model: Hardware Inventory

This feature has no application database. Its operational record contains these sections.

## System

- Manufacturer and product family
- Ubuntu release and kernel
- Firmware/BIOS vendor and version, excluding serial identifiers

## Compute and Memory

- CPU model, architecture, core count, and thread count
- Installed memory total

## Storage

- Device name, capacity, transport, rotational status, and model
- Filesystem type and mount point where useful, excluding UUIDs

## Graphics

- PCI vendor/device and model
- Bound kernel driver and available modules
- Vendor-driver status where applicable

## Networking and Bluetooth

- Ethernet and Wi-Fi controller models and bound drivers
- Network interface roles without MAC or IP addresses
- Bluetooth controller presence and driver visibility

## USB and Audio

- Relevant attached USB device classes/models
- PipeWire/ALSA audio devices and profiles, including potential HDMI paths

## Validation

Every documented claim must be traceable to a live command. Missing access, absent tools, and untested capabilities must be stated rather than inferred.
