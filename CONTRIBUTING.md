# Contributing

## Releasing

Releases are published to [pub.dev](https://pub.dev/packages/gleap_sdk) by GitHub Actions ([`.github/workflows/release.yml`](.github/workflows/release.yml)) when a version tag is pushed. The tag is the plain version (`18.2.0`, no `v`), the same across all Gleap SDKs. Nobody runs `flutter pub publish` by hand.

1. In a PR, bump the version:
   - `version` in `pubspec.yaml`
   - the native pins (all the same `X.Y.Z`):
     - `ios/gleap_sdk.podspec` (CocoaPods): `s.version          = 'X.Y.Z'` and `s.dependency 'Gleap', 'X.Y.Z'`
     - `ios/gleap_sdk/Package.swift` (Swift Package Manager): `.package(url: "https://github.com/GleapSDK/Gleap-iOS-SDK.git", from: "X.Y.Z")`
     - `android/build.gradle`: `io.gleap:gleap-android-sdk`

     The Gleap iOS tag `X.Y.Z` must exist on GleapSDK/Gleap-iOS-SDK before this release is tagged, or Swift Package Manager apps can't resolve the package (and CocoaPods apps need it on trunk, or the `:git`/`:tag` Podfile line from the README after 2026-12-02).
   - a `## X.Y.Z` section at the top of `CHANGELOG.md` (pub.dev shows it, and it becomes the GitHub Release notes)
2. Merge the PR into `main`.
3. Tag the merge commit and push the tag:

   ```sh
   git switch main && git pull --ff-only
   git tag X.Y.Z && git push origin X.Y.Z
   ```

The workflow checks that the tag equals the `pubspec.yaml` version, runs `flutter pub get`, `flutter analyze --no-fatal-infos` and `flutter pub publish --dry-run`, then `flutter pub publish --force` via [pub.dev automated publishing](https://dart.dev/tools/pub/automated-publishing) (GitHub OIDC, no stored credentials), and finally creates the GitHub Release. [`.github/workflows/ci.yml`](.github/workflows/ci.yml) runs the same checks on every pull request and push to `main`. The Flutter version is pinned in both workflows (`FLUTTER_VERSION`).

**One-time setup** (pub.dev → `gleap_sdk` → Admin → Automated publishing):

| Field | Value |
| --- | --- |
| Enable publishing from GitHub Actions (push events) | on |
| Repository | `GleapSDK/Flutter-SDK` |
| Tag pattern | `{{version}}` |
| Require GitHub Actions environment | off |

## iOS (Swift Package Manager and CocoaPods)

The iOS sources live in the Swift package at `ios/gleap_sdk/` (layout from [Swift Package Manager for plugin authors](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-plugin-authors)): `Package.swift`, the public header in `Sources/gleap_sdk/include/gleap_sdk/`, the implementation in `Sources/gleap_sdk/`. The package depends on the `FlutterFramework` package the Flutter tool generates (Flutter 3.41+) and on the `Gleap` product of GleapSDK/Gleap-iOS-SDK. `ios/gleap_sdk.podspec` builds the same sources for CocoaPods apps (Flutter < 3.41 or Swift Package Manager turned off), as the docs recommend for now. `GleapSdkPlugin.m` imports Gleap as `<Gleap/Gleap.h>` under CocoaPods and `@import Gleap` under Swift Package Manager.

Both `pubspec.yaml` files set `config: enable-swift-package-manager: true` (only read for this repo, not by apps), so the example stays on Swift Package Manager on Flutter 3.41–3.43 without a global `flutter config` (3.44+ has it on by default). The example app has no Podfile.

Building the example for the simulator (`flutter build ios --simulator` fails on engines without an x86_64 slice):

```sh
cd example && flutter pub get && flutter build ios --config-only --simulator --debug
cd ios && xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' ARCHS=arm64 build
```

Before the Gleap iOS tag of a new version exists, point `Package.swift` at `branch: "main"` (or `path:` to a local checkout) for the build only, and commit `from: "X.Y.Z"`.

To check the CocoaPods build, use a copy of the example outside the repo: set `enable-swift-package-manager: false` and the `gleap_sdk` path to this checkout in its `pubspec.yaml`, take `ios/` from a CocoaPods Flutter app (for example the example before 19.0.0: `git archive a45a054 example/ios`), add `pod 'Gleap', :git => 'https://github.com/GleapSDK/Gleap-iOS-SDK.git', :branch => 'main'` (or `:tag => 'X.Y.Z'`) to the Runner target in its Podfile, run `pod update Gleap gleap_sdk` in `ios/` (with `LANG=en_US.UTF-8`), then the same two build commands.
