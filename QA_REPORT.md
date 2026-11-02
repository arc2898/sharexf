# ShareXF static QA report

**Checked:** 2 November 2026  
**Scope:** source syntax, structured text, stylesheets, static website and shared-library tests in the available Linux sandbox.

## Results

| Check | Files / tests | Result |
|---|---:|---|
| JavaScript syntax (`node --check`) | 666 | 0 errors |
| JSON parsing | 86 | 0 errors |
| XML, plist and SVG parsing | 54 | 0 errors |
| Python compilation | 5 | 0 errors |
| Shell syntax (`bash -n`) | 15 | 0 errors |
| YAML parsing | 8 | 0 errors |
| CSS parsing (`tinycss2`) | 31 | 0 errors |
| Static website HTML parsing | 4 | 0 parser errors |
| Shared-library tests | 37 | 37 passed |

## Environment-limited checks

- 43 macOS / Windows / Linux mesh tests could not run because the `ws` npm dependency is not installed in this sandbox. Seven mesh tests that did not need that dependency passed. No other mesh-test failure category was observed.
- `shared/test/movebench.js` was not run because it requires the same missing `ws` dependency.
- Native macOS, Windows, Android and Linux package builds were not executed here. Those require platform SDKs, native compilers, build dependencies and/or network package downloads. The matching GitHub Actions workflows are provided for those runners.
- A full live device-pairing, remote-input, camera, notification and file-transfer QA session was not possible without paired physical devices or configured emulators.

## Implementation details

- Update checks default to `arc2898/sharexf`; `SHAREXF_UPDATE_REPOSITORY` can override it.
- Linux update asset selection recognizes RPM packages as well as DEB and AppImage packages.
- macOS, Windows, Linux and Android app themes, browser-extension marks and launcher icons use the gold / biscuit / ivory / charcoal palette. Sidebar illustrations use warm ash and charcoal neutrals.
- Existing third-party copyright and license notices were retained. Do not remove them when redistributing bundled components.

This report records automated checks run in the sandbox. It is not a claim of platform-native release certification or a complete manual line-by-line code audit.
