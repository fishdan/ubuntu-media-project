# Research: DualSense Controller

## Decision: Use the upstream kernel Sony driver

Ubuntu's current kernel contains signed `hid_playstation` support for Sony controller USB and Bluetooth IDs. No third-party kernel driver is justified.

## Decision: Use Kodi's native joystick add-on first

Ubuntu packages `kodi-peripheral-joystick` against Kodi's matching peripheral API. Native joystick events avoid turning gamepad input into keyboard input inside Kodi and establish the correct path for later Steam compatibility.

## Decision: Use input-remapper only as an explicit media mode

Ubuntu packages input-remapper 2.2.0 with Wayland support, macros, and automatic device handling. Its virtual keyboard/mouse output is useful for browser/desktop control but can conflict with games. The media preset therefore needs clear enable/disable commands and must be disabled before Steam.

## Decision: Stage mappings that depend on later features

Brave is delivered in Spec 009, pointer/keyboard behavior in Spec 010, Steam in Spec 011, and universal return-home in Spec 012. Spec 008 can define/test controller primitives and hooks, but final cross-application acceptance belongs to those dependent features.

## Decision: Keep device addresses out of Git

Bluetoothctl necessarily displays the controller address during pairing. Commands will use a session-local value, and tracked evidence will record the controller name, transport, driver, capabilities, and result without the address.
