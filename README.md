# ShareXF

**Share files, screens, input and device features across your computers and Android devices.**

ShareXF is a privacy-minded, open-source device connectivity suite for macOS, Windows, Linux and Android. Pair devices on your local network or through supported direct connections, then enable only the features you use.

## Platforms

| Platform | Targets | Build output |
|---|---|---|
| macOS 13+ | Intel (x64) and Apple silicon (arm64) | .dmg |
| Windows 10+ | x64 and ARM64 | .exe installer |
| Linux | x86_64; Debian/Ubuntu and Fedora-family packages | .deb, .rpm, .AppImage |
| Android 10+ | Phones and tablets | .apk |

Prebuilt packages are published on the [GitHub Releases page](https://github.com/arc2898/sharexf/releases). A package is available only after its corresponding build has completed and been published.

## Features

- Send and receive files between paired devices.
- Share a mouse and keyboard across supported computers; use remote input from Android.
- Synchronize clipboard content and notifications when enabled.
- Use supported phone, screen, audio and camera features.
- View device connection and battery status.
- Use optional device automation and multi-device workflows.

Feature availability depends on the operating system, permissions, connection type and companion app version.

## Build from source

Requirements: Node.js 20+ and npm for desktop clients; Java 21 and Android SDK for Android; Xcode for macOS; Visual Studio Build Tools / Windows SDK for Windows; and a C compiler plus platform development libraries for Linux.

Desktop:
```sh
cd mac       # or windows / linux
npm install
npm start
```

Android:
```sh
cd android
./gradlew assembleRelease
```

Build scripts and CI workflows are in each platform directory and `.github/workflows/`. The Linux workflow builds DEB, RPM and AppImage packages. Run it from **Actions → Build Linux → Run workflow**.

## Website and legal

The static website and deployment workflow are in `website/` and `.github/workflows/pages.yml`. To publish it, set **Settings → Pages → Source → GitHub Actions** and confirm the deployment in the Actions tab. The expected URL is https://arc2898.github.io/sharexf/.

- [Privacy policy](https://arc2898.github.io/sharexf/privacy.html)
- [Terms and conditions](https://arc2898.github.io/sharexf/terms.html)

The application is designed for direct device-to-device communication. Optional update checks may contact GitHub. Read the privacy policy for details.

## Source package

The complete multi-platform application tree is supplied in the ShareXF source archive. To import it into this repository, extract the archive and run `python3 publish-to-github.py` from its root directory. See [PUBLISHING.md](PUBLISHING.md). This keeps generated build files and local signing credentials out of the repository.

## Contributing and licensing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting changes. ShareXF is distributed under the GNU General Public License v3.0; see [LICENSE](LICENSE). Third-party components and required notices are listed in [THIRD_PARTY_NOTICES](THIRD_PARTY_NOTICES) and `licenses/`.

## Security

Do not publish private keys, signing certificates, keystores, passwords or device pairing secrets. Report security issues privately to the repository owner rather than posting exploit details in a public issue.

## Publishing

See [PUBLISHING.md](PUBLISHING.md) for enabling GitHub Pages and publishing the full platform source from the supplied source archive.

## QA

See [QA_REPORT.md](QA_REPORT.md) for sandbox syntax and shared-library test results, plus checks blocked by missing platform dependencies.
