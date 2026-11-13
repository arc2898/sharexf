# Alpine Linux package status

A native Alpine `.apk` is **not provided yet**.

The current Linux desktop package embeds the standard Electron Linux runtime, which targets
glibc. Alpine uses musl libc. Adding an APKBUILD around the existing Debian package would only
repackage a binary that may not start; installing `gcompat` is not a demonstrated compatibility
solution for Electron and ShareXF's native helpers.

Before publishing an Alpine package, validate all of the following on supported Alpine releases:

1. Electron starts on musl without relying on an unverified glibc compatibility layer.
2. Every native helper and bundled executable links against available musl-compatible libraries.
3. Screen capture, input injection, audio, Bluetooth, networking, and desktop integration work
   on the intended Alpine desktop environments.
4. The APK installs, upgrades, and removes cleanly in a clean Alpine VM.

Until those checks pass, use the upstream AppImage only if the target system has a working
FUSE/glibc environment, or use a supported glibc-based Linux distribution. Do not publish a
placeholder APKBUILD that implies Alpine compatibility.
