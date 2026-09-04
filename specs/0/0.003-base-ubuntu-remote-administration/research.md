# Research: Base Ubuntu and Remote Administration

## Decision: Treat the installed Ubuntu 26.04.1 LTS host as the planning target

- Rationale: The live environment reports Ubuntu 26.04.1 LTS (`resolute`). Reinstalling or downgrading would discard the available baseline and would not answer the user's immediate operational need.
- Alternatives considered: Reinstall an older Ubuntu LTS to match historical documentation; rejected because it would be destructive and is not required to establish remote administration.
- Follow-up completed: The constitution and project-wide mission now use Ubuntu 26.04 LTS as the supported baseline.

## Decision: Inspect before changing network configuration

- Rationale: NetworkManager is the desktop-oriented control plane and can show the actual Ethernet, Wi-Fi, connection, and DHCP state. Existing Wi-Fi fallback must not be removed while Ethernet becomes primary.
- Alternatives considered: Replace NetworkManager with hand-managed netplan or systemd-networkd; rejected because it adds unnecessary risk to a working desktop and conflicts with the recovery requirement.

## Decision: Use OpenSSH key authentication while preserving local recovery

- Rationale: OpenSSH is standard on Ubuntu, supports VS Code Remote - SSH, and permits password authentication to be reviewed and disabled only after key access is proven. The local desktop and physical console remain an escape path.
- Alternatives considered: Password-only SSH; rejected because it is weaker for ongoing administration. Disabling all local recovery; rejected by the constitution.

## Decision: Prove access across a reboot from a second client

- Rationale: A successful pre-reboot login does not prove that the service, address, firewall, key authorization, and network connection return after boot. The acceptance check must originate from a separate administrator client and record the observed hostname/IP without recording secrets.
- Alternatives considered: Checking only `systemctl is-active ssh`; rejected because it does not validate end-to-end access.

## Decision: Keep hostname and DHCP reservation as documented decisions

- Rationale: A stable hostname and a router-side DHCP reservation make VS Code Remote - SSH and future appliance operations predictable while avoiding hard-coded static network settings on the host.
- Alternatives considered: A host-side static IP; rejected until the router/network topology is known and because it can create address conflicts.
