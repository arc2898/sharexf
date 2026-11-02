# ShareXF Next: cross-platform roadmap

This fork starts from the upstream ShareXF GNOME Shell extension. The first
change is a visual refresh of its GTK preferences dashboard; the existing
KDE Connect packet protocol and plugin implementations remain the source of
truth for device interoperability.

## Current capability inherited from ShareXF

| Requested capability | Existing implementation |
| --- | --- |
| Android pairing and notifications | KDE Connect LAN backend and notification plugin |
| File and link sharing | Share and SFTP plugins |
| Battery information | Battery plugin, including charge/discharge estimates |
| Remote keyboard/mouse | Mousepad plugin and input component |
| Device automation | Run Commands plugin (user-configured commands) |

These are existing capabilities, not newly implemented features in this
visual-refresh milestone. Transfer throughput has not yet been benchmarked or
changed.

## Platform boundary

ShareXF is not a cross-platform desktop application: it is a GNOME Shell
extension with GJS, GTK 3, GNOME Shell, and Linux desktop-service dependencies.
The Android application is a separate KDE Connect project and is not included
in this source archive. Windows support therefore cannot be achieved by
changing the GNOME extension alone.

A maintainable Linux + Android + Windows product should split into:

1. **Protocol core** — packet framing, TLS identity, pairing, capability
   negotiation, transfer jobs, and device state, independent of UI.
2. **Linux host adapter** — GNOME Shell/GTK integration, UPower, desktop
   notifications, input injection, and file manager integration.
3. **Windows host adapter** — Windows notifications, input APIs, battery and
   power APIs, file dialogs, startup/background service, and firewall setup.
4. **Android client** — a compatible KDE Connect Android client or a separately
   maintained companion app. This repository does not contain that app.
5. **Shared dashboard** — a cross-platform UI can be introduced after the
   protocol and host-adapter boundaries are stable.

## Recommended implementation order

- [x] Refresh the existing GTK preferences dashboard without changing protocol
      behavior.
- [ ] Add transfer-job instrumentation and establish throughput baselines.
- [ ] Design a platform-neutral protocol-core API and compatibility tests.
- [ ] Implement a Windows host adapter against the same protocol tests.
- [ ] Build battery history and automation scheduling on top of explicit,
      permissioned device APIs.
- [ ] Evaluate a shared UI after Linux and Windows adapters are functional.

## Safety and compatibility notes

Remote input and remote commands are powerful features. Keep them opt-in,
per-device, visible to the user, and protected by the existing pairing and
permission model. Do not silently execute commands received from an unpaired
or newly paired device.
