---

description: "Task list for Base Ubuntu and Remote Administration"
---

# Tasks: Base Ubuntu and Remote Administration

**Input**: Design documents from `specs/0/0.003-base-ubuntu-remote-administration/`

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `quickstart.md`

**Tests**: No separate automated test suite is required. The command-based acceptance checks in `quickstart.md` are mandatory validation tasks.

**Organization**: Tasks are ordered by dependency. The single P1 user story is independently testable after the foundational host inspection and network/release decisions are complete.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish the feature scope and capture facts from the already-installed host.

- [x] T001 [P] Record the live Ubuntu release, desktop/session state, hostname, administrator account, and hardware identity in `.config/ai/progress.ai` using the commands in `specs/0/0.003-base-ubuntu-remote-administration/quickstart.md`.
- [x] T002 Adopt Ubuntu 26.04.1 LTS as the supported project baseline and reconcile `specs/0/0.003-base-ubuntu-remote-administration/spec.md`, `.specify/memory/constitution.md`, `README.md`, and `setup.md` accordingly.
- [x] T003 [P] Select the stable hostname and router-side DHCP reservation approach, and record the decision without recording Wi-Fi credentials in `specs/0/0.003-base-ubuntu-remote-administration/quickstart.md` and `.config/ai/progress.ai`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Inspect and preserve the network and local recovery paths before enabling remote administration.

**Checkpoint**: Do not begin user-story tasks until Ethernet, Wi-Fi fallback, the normal Ubuntu desktop, and physical-console recovery are confirmed.

- [x] T004 Inspect NetworkManager device, connection, route, and DHCP state on the appliance and record the actual Ethernet and Wi-Fi interface names in `.config/ai/progress.ai`.
- [x] T005 [P] Confirm the normal Ubuntu desktop and physical-console login remain available, and document the recovery path in `specs/0/0.003-base-ubuntu-remote-administration/data-model.md`.
- [x] T006 Configure Ethernet as the preferred connection while retaining a tested Wi-Fi management fallback, then record the observed result in `.config/ai/progress.ai`.
- [x] T007 Install `openssh-server`, enable the `ssh` service, and verify its listening state on the appliance using the commands documented in `specs/0/0.003-base-ubuntu-remote-administration/quickstart.md`.

---

## Phase 3: User Story 1 - Recoverable Remote Administration (Priority: P1) MVP

**Goal**: After the appliance is prepared locally, it boots unattended without a keyboard or monitor and an administrator can connect to the existing Ubuntu 26.04.1 LTS desktop host from a separate laptop using an SSH key and VS Code Remote - SSH, including after a normal reboot, without losing local recovery or Wi-Fi fallback.

**Independent Test**: With keyboard and monitor disconnected, the appliance completes a normal boot; from a separate administrator client, key-only SSH succeeds before reboot and after reboot; the remote terminal reports the expected hostname and active SSH service; VS Code Remote - SSH opens the host; the local desktop remains usable when peripherals are reconnected.

### Implementation

- [x] T008 [P] [US1] When the administrator laptop is available, create or select its key pair and transfer only its public key to the appliance user account, leaving the private key on the laptop.
- [x] T009 [US1] Validate key-only SSH from the separate laptop before reboot and record the hostname, client, connection target, and result without recording secrets in `.config/ai/progress.ai`.
- [x] T010 [US1] Disconnect the keyboard and monitor, reboot the appliance only after the pre-reboot SSH check succeeds, then validate unattended post-boot key-only SSH, active `ssh`, and NetworkManager connectivity from the separate laptop using `specs/0/0.003-base-ubuntu-remote-administration/quickstart.md`.
- [x] T011 [US1] Configure and validate a VS Code Remote - SSH host entry for the selected hostname or DHCP-reserved address, and record the connection result in `.config/ai/progress.ai`.
- [x] T012 [US1] Confirm the local Ubuntu desktop, physical-console recovery, Ethernet preference, and Wi-Fi fallback after reboot, and record the acceptance evidence in `.config/ai/progress.ai`.

**Checkpoint**: User Story 1 is complete only when SSH and VS Code Remote - SSH work after reboot and all recovery paths remain available.

---

## Phase 4: Polish and Cross-Cutting Concerns

**Purpose**: Make the validated setup reproducible and ready for the next appliance feature.

- [x] T013 [P] Update `README.md`, `setup.md`, and `specs/0/0.003-base-ubuntu-remote-administration/quickstart.md` with the final supported Ubuntu release, hostname convention, DHCP reservation approach, and recovery procedure.
- [x] T014 [P] Review repository changes for secrets, private keys, Wi-Fi credentials, cookies, and tokens, and record the security review result in `.config/ai/progress.ai`.
- [x] T015 Run the complete `specs/0/0.003-base-ubuntu-remote-administration/quickstart.md` acceptance sequence and record the final result in `.config/ai/progress.ai` before beginning the next roadmap feature.

---

## Dependencies and Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No host-changing work may begin until the Ubuntu release decision is recorded.
- **Foundational (Phase 2)**: Depends on Phase 1; blocks all user-story tasks.
- **User Story 1 (Phase 3)**: Depends on T004 through T007 and is the MVP.
- **Polish (Phase 4)**: Depends on successful completion of User Story 1.

### User Story Dependencies

- **User Story 1 (P1)**: Starts after the foundational network, desktop-recovery, and SSH service checks. It has no dependency on later appliance features.

### Within User Story 1

- T008 must precede T009.
- T009 must pass before T010.
- T010 must pass before T011 and T012.
- T012 must pass before the feature is accepted.

### Parallel Opportunities

- T001 and T003 can be prepared in parallel because both are documentation decisions, but T002 must resolve the release baseline before host changes.
- T005 can run in parallel with T004 once the release decision is recorded.
- T013 and T014 can run in parallel after User Story 1 acceptance.

---

## Implementation Strategy

### MVP First

1. Complete Phase 1 and resolve the Ubuntu 26.04 baseline decision.
2. Complete Phase 2 without disabling any recovery path.
3. Complete User Story 1 through post-reboot SSH and VS Code validation.
4. Stop and validate the appliance from both the separate client and physical console.

### Incremental Delivery

1. Establish and document the release, hostname, and network facts.
2. Enable OpenSSH while retaining local and Wi-Fi recovery.
3. Prove key-only SSH before and after reboot.
4. Prove VS Code Remote - SSH access.
5. Record the final acceptance evidence and only then begin appliance customization.

## Notes

- Every task includes a repository or host file path for traceability.
- No private key, password, Wi-Fi credential, browser profile, cookie, or token belongs in this repository.
- Automatic login and automatic media startup are explicitly outside this feature.
