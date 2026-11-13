# Publishing ShareXF

The project website is stored in `website/` and deployed by `.github/workflows/pages.yml`.
The repository is `https://github.com/arc2898/sharexf`.

## Publish the full source tree

The website and project overview have already been placed in the GitHub repository. To add the complete desktop, helper, Android and integration source tree from this package, extract the archive and run this from the extracted `ShareXF` directory:

```sh
python3 publish-to-github.py
```

Requirements: Python 3, Git, and an authenticated GitHub credential manager with write access to `arc2898/sharexf`. The script clones the existing repository, copies the project files while excluding dependency caches, generated build output and local signing secrets, then commits and pushes to `main`. It does not delete or modify your original extracted folder.

## Enable the website

1. Open [ShareXF repository settings](https://github.com/arc2898/sharexf/settings/pages).
2. Under **Build and deployment → Source**, select **GitHub Actions**.
3. Save the setting if GitHub shows a Save button.
4. Open the [Actions tab](https://github.com/arc2898/sharexf/actions) and wait for **Deploy ShareXF website** to finish successfully.

The website URL is <https://arc2898.github.io/sharexf/>. The privacy and terms pages are linked in the site's footer. GitHub Pages publishes the site publicly; do not place secrets or private files in `website/`.

## Build installers

The platform workflows are manually dispatched from **Actions**:

- **Build macOS**: produces separate Intel (`x64`) and Apple silicon (`arm64`) DMGs. Release uploads also include stable `ShareXF-latest-*.dmg` aliases for the Homebrew Cask at `Casks/sharexf.rb`. Developer ID signing and notarization require the corresponding repository secrets.
- **Build Windows**: produces x64 and ARM64 installers on a Windows runner.
- **Build Linux**: produces `.deb`, `.rpm`, AppImage and strict-confinement Snap packages on Ubuntu. It also builds an x86_64 Flatpak bundle from the generated Debian package; the Flatpak needs broad host/device permissions for ShareXF's input and device integrations, and is not yet a Flathub submission.
- **Build Android**: produces standard and full APK variants. Without an Android signing keystore secret, the build is for testing and will not update-install over a differently signed copy.

To install the macOS Cask directly, use `brew install --cask https://raw.githubusercontent.com/arc2898/sharexf/main/Casks/sharexf.rb`. For Flatpak development builds, run `packaging/flatpak/build.sh` on a supported x86_64 Linux host with Flatpak, Flatpak Builder, and Snapcraft installed.

An Alpine `.apk` is intentionally not generated: the current Electron runtime targets glibc, while Alpine uses musl. See `packaging/alpine/README.md`; a package should only be added after native runtime and helper compatibility are demonstrated. For release uploads, provide an existing version tag in the workflow's `tag` input. Leave it blank to create downloadable workflow artifacts without publishing a release. Signing credentials must never be committed to the repository.
