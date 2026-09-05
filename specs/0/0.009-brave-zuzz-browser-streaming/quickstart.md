# Acceptance and recovery

1. Run `scripts/install-browser-media.sh` as the graphical user.
2. Run `~/.local/bin/launch-zuzz` or select Zuzz in the GNOME applications list.
3. Confirm projector presentation and use the dedicated profile to sign in locally, using GNOME's on-screen keyboard (`org.gnome.desktop.a11y.applications screen-keyboard-enabled`) for text fields. Never send credentials to the assistant or store them in Git.
4. Play a stream and confirm receiver sound, video, pointer/click/back, and fullscreen behavior.
5. Close Firefox or run `systemctl --user stop zuzz-media.service`; confirm Kodi returns and native controller navigation works.
6. Relaunch and confirm expected account-session persistence. Login expiry remains controlled by the service.

The on-screen keyboard works directly in Firefox's website fields, unlike the previous Brave-based launcher. Universal controller Home and Kodi menu integration belong to Spec 012.
