# Publishing ShareXF

The repository contains the ShareXF application source for desktop, Android and platform helper components.

## Publish the full source tree

To add the complete desktop, helper, Android and integration source tree from this package, extract the archive and run this from the extracted `ShareXF` directory:

```sh
python3 publish-to-github.py
```

Requirements: Python 3, Git, and an authenticated GitHub credential manager with write access to `arc2898/sharexf`. The script clones the existing repository, copies the project files while excluding dependency caches, generated build output and local signing secrets, then commits and pushes to `main`. It does not delete or modify your original extracted folder.

## Build installers

The platform workflows are manually dispatched from **Actions**:

- **Build macOS**: produces separate Intel (`x64`) and Apple silicon (`arm64`) DMGs. Developer ID signing and notarization require the corresponding repository secrets.
- **Build Windows**: produces x64 and ARM64 installers on a Windows runner.
- **Build Linux**: produces `.deb`, `.rpm` and AppImage packages on Ubuntu.
- **Build Android**: produces standard and full APK variants. Without an Android signing keystore secret, the build is for testing and will not update-install over a differently signed copy.

For release uploads, provide an existing version tag in the workflow's `tag` input. Leave it blank to create downloadable workflow artifacts without publishing a release. Signing credentials must never be committed to the repository.
