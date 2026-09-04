# Data Model: Base Ubuntu and Remote Administration

This feature has no application database. The following operational records are the evidence that the appliance baseline is configured and recoverable.

## Host Baseline

- `os_release`: observed distribution, version, codename, and desktop edition
- `hostname`: selected stable host name
- `admin_user`: local administrator account used for SSH
- `hardware_identity`: manufacturer/model captured from the machine

Validation:

- The OS release is recorded from `/etc/os-release`.
- The hostname is unique on the local network.
- The administrator account is not a shared or root-only login.

## Network Profile

- `ethernet_interface`: actual wired interface name and connection state
- `wifi_interface`: actual wireless interface name and fallback state
- `primary_connection`: Ethernet when available
- `fallback_connection`: configured Wi-Fi profile, without its password in Git
- `dhcp_reservation`: router-side reservation decision and observed address

Validation:

- NetworkManager reports the expected interfaces.
- Ethernet is preferred when connected.
- Wi-Fi remains usable as a management fallback.
- Credentials are never recorded in repository artifacts.

## Remote Access

- `ssh_service`: OpenSSH service and listening status
- `authorized_key`: administrator public-key fingerprint only
- `client_host`: separate machine used for end-to-end validation
- `reboot_result`: post-reboot connection result and timestamp
- `vscode_remote_ssh`: successful editor connection result

Validation:

- Key authentication succeeds without copying a private key to the appliance.
- The same client reconnects after reboot.
- VS Code Remote - SSH opens the repository or home directory.
- Password/root access changes are made only after key access is proven.

## Recovery Path

- `physical_console`: local keyboard/display login remains available
- `desktop_session`: normal Ubuntu desktop remains usable
- `ssh_recovery_notes`: documented route when Ethernet or Wi-Fi changes

Validation:

- No automatic media startup is introduced by this feature.
- A failed remote-access change can be reversed from the physical console.
