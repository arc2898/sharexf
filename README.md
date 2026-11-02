# ShareXF

**Share files, screens, input and device features across your computers and Android devices.**

ShareXF is a privacy-minded, open-source device connectivity suite for macOS, Windows, Linux and Android. Pair devices on your local network or through supported direct connections, then enable only the features you use.

## Platforms

| Platform | Targets | Build output |
|---|---|---|
| macOS 13+ | Intel (`x64`) and Apple silicon (`arm64`) | `.dmg` |
| Windows 10+ | x64 and ARM64 | `.exe` installer |
| Linux | x86_64; Debian/Ubuntu and Fedora-family packages | `.deb`, `.rpm`, `.AppImage` |
| Android 10+ | Phones and tablets | `.apk` |

Release packages will appear on the [GitHub Releases page](https://github.com/arc2898/sharexf/releases) after their platform builds complete. Build workflows can be run manually from **Actions**.

## Features

- Send and receive files between paired devices.
- Share a mouse and keyboard across supported computers; use remote input from Android.
- Synchronize clipboard content and notifications when enabled.
- View and control supported phone, screen, audio and camera features.
- See device connection and battery status.
- Use optional device automation and multi-device workflows.
- Pair locally without a ShareXF account or mandatory cloud relay.

Feature availability depends on the operating system, permissions, connection type and companion app version. See the platform-specific notes in `docs/` before enabling system-level integrations.

## Build from source

### Requirements

- Node.js 20 or later and npm for desktop clients.
- Java 21 and Android SDK components for Android builds.
- Xcode and Command Line Tools for macOS builds.
- Visual Studio Build Tools / Windows SDK for Windows native helpers.
- A C compiler and the platform development libraries listed in the Linux workflow for Linux helpers.

### Desktop clients

```sh
cd mac       # or windows / linux
npm install
npm start
```

Build commands and native helper setup are documented in the corresponding platform directory and `.github/workflows/`.

### Android

```sh
cd android
./gradlew assembleRelease
```

### Linux packages

The Linux packaging workflow builds `.deb`, `.rpm` and AppImage outputs on an Ubuntu runner. Run **Actions → Build Linux → Run workflow** to produce artifacts. The resulting RPM targets Fedora/RHEL-family systems; package dependencies may differ by distribution release.

## Publishing

To upload the complete source tree to the project repository, see [PUBLISHING.md](PUBLISHING.md) and run `python3 publish-to-github.py` from the extracted project directory.

## Website

The static project website and GitHub Pages deployment workflow are included. Enable **Settings → Pages → Source → GitHub Actions** to publish it at <https://arc2898.github.io/sharexf/>. See [PUBLISHING.md](PUBLISHING.md).

## Privacy and terms

- [Privacy policy](https://arc2898.github.io/sharexf/privacy.html)
- [Terms and conditions](https://arc2898.github.io/sharexf/terms.html)

The application is designed for direct device-to-device communication. Optional update checks can contact GitHub. Read the policy for details and for the limits of this summary.

## Contributing and licensing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting changes. ShareXF is distributed under the GNU General Public License v3.0; see [LICENSE](LICENSE). Third-party components and required notices are listed in [THIRD_PARTY_NOTICES](THIRD_PARTY_NOTICES) and `licenses/`.

## Security

Do not publish private keys, signing certificates, keystores, passwords or device pairing secrets. Report security issues privately to the repository owner rather than posting exploit details in a public issue.
