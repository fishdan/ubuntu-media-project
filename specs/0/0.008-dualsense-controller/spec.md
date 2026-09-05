# Feature Specification: DualSense Controller

**Status**: Complete for current scope; downstream application integration and projector/receiver acceptance remain staged.

Pair and reconnect the PS5 DualSense controller, then create and test couch-friendly media mappings for navigation, selection, back, playback, volume, pointer support, keyboard access, and return-home. The mapping must work in Kodi and Brave without interfering with Steam Input.

## Acceptance Criteria

- A PS5 DualSense pairs over Bluetooth, reconnects without a cable, and binds to the in-kernel `hid_playstation` driver.
- Kodi recognizes the controller through its native joystick support and accepts directional navigation, selection, back, and playback controls.
- Desktop/browser media mappings provide navigation, pointer movement, click, back, playback, and volume without storing the controller Bluetooth address in Git.
- The media remapping layer can be disabled before Steam so Steam receives the native controller without duplicated keyboard/mouse events.
- Keyboard invocation and universal return-home hooks use stable commands owned by their later dedicated specs; placeholders must not pretend those features are complete.
- SSH and remote `kodi-send` recovery remain available if a controller mapping traps or obscures the graphical session.
- Pairing, disconnect/reconnect, and reboot behavior are recorded with human-visible couch-side results.
