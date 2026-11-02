#!/bin/sh
# ShareXF — Copyright (C) 2026 inukaasith. GPL-3.0, see LICENSE.
# Builds mac-helper with swiftc directly (SwiftPM's manifest API is broken in the installed
# Command Line Tools). Pass x64 or arm64 to cross-build; without an argument, use the host.
# Output: .build/release/sharexf-helper, sharexf-dockstub and sharexf-calls
set -e
cd "$(dirname "$0")"
mkdir -p .build/release
ARCH=${1:-$(uname -m)}
case "$ARCH" in
  x64|x86_64) SWIFT_ARCH=x86_64 ;;
  arm64|aarch64) SWIFT_ARCH=arm64 ;;
  *) echo "Error: unsupported macOS architecture '$ARCH' (use x64 or arm64)." >&2; exit 2 ;;
esac
TARGET="$SWIFT_ARCH-apple-macos13.0"

swiftc -O -swift-version 5 -target "$TARGET" \
  -I Sources/VirtualDisplayBridge/include \
  -framework CoreGraphics -framework AppKit -framework ApplicationServices -framework IOKit -framework ScreenCaptureKit -framework CoreMedia -framework NetFS -framework CoreBluetooth -framework CoreWLAN -framework CoreLocation -lsqlite3 \
  -Xlinker -sectcreate -Xlinker __TEXT -Xlinker __info_plist -Xlinker Sources/sharexf-helper/Info.plist \
  Sources/sharexf-helper/*.swift -o .build/release/sharexf-helper
echo "built .build/release/sharexf-helper"
# Multi-device's helper (docs/multi-device.md): the same sources with -D MULTI, several watched edges
# (the #if MULTI parts of Capture.swift and main.swift); only mac/mesh starts it.
swiftc -O -swift-version 5 -target "$TARGET" -D MULTI \
  -I Sources/VirtualDisplayBridge/include \
  -framework CoreGraphics -framework AppKit -framework ApplicationServices -framework IOKit -framework ScreenCaptureKit -framework CoreMedia -framework NetFS -framework CoreBluetooth -framework CoreWLAN -framework CoreLocation -lsqlite3 \
  -Xlinker -sectcreate -Xlinker __TEXT -Xlinker __info_plist -Xlinker Sources/sharexf-helper/Info.plist \
  Sources/sharexf-helper/*.swift -o .build/release/sharexf-helper-multi
echo "built .build/release/sharexf-helper-multi"
swiftc -O -swift-version 5 -target "$TARGET" -framework AppKit \
  Sources/sharexf-dockstub/main.swift -o .build/release/sharexf-dockstub
echo "built .build/release/sharexf-dockstub"
# The calls' sound over Bluetooth (mac/callaudio.js), its own process: only it loads IOBluetooth.
swiftc -O -swift-version 5 -target "$TARGET" -framework IOBluetooth \
  -Xlinker -sectcreate -Xlinker __TEXT -Xlinker __info_plist -Xlinker Sources/sharexf-calls/Info.plist \
  Sources/sharexf-calls/main.swift -o .build/release/sharexf-calls
echo "built .build/release/sharexf-calls"
# Camera › Virtual camera (mac/vcam.js): the Camera Extension and the tool that installs and feeds
# it (packed into ShareXF.app by mac/build-app.sh when it's signed for system extensions).
swiftc -O -swift-version 5 -target "$TARGET" -framework CoreMediaIO -framework CoreMedia -framework CoreVideo -framework IOKit   Sources/sharexf-camera/main.swift -o .build/release/sharexf-camera
echo "built .build/release/sharexf-camera"
swiftc -O -swift-version 5 -target "$TARGET" -framework CoreMediaIO -framework CoreMedia -framework CoreVideo -framework SystemExtensions -framework VideoToolbox   Sources/sharexf-vcam/main.swift -o .build/release/sharexf-vcam
echo "built .build/release/sharexf-vcam"
# Share menu extension (packed into ShareXF.app/Contents/PlugIns by mac/build-app.sh).
swiftc -O -swift-version 5 -target "$TARGET" -application-extension -parse-as-library \
  -module-name ShareXFShare -framework AppKit -Xlinker -e -Xlinker _NSExtensionMain \
  Sources/sharexf-share/ShareViewController.swift -o .build/release/sharexf-share
echo "built .build/release/sharexf-share"
