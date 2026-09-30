# Contributing

## Releasing

Releases are published to [pub.dev](https://pub.dev/packages/gleap_sdk) by GitHub Actions ([`.github/workflows/release.yml`](.github/workflows/release.yml)) when a version tag is pushed. The tag is the plain version (`18.2.0`, no `v`), the same across all Gleap SDKs. Nobody runs `flutter pub publish` by hand.

1. In a PR, bump the version:
   - `version` in `pubspec.yaml`
   - the native pins: the Gleap iOS SDK requirement `.package(url: "https://github.com/GleapSDK/Gleap-iOS-SDK.git", from: "X.Y.Z")` in `ios/gleap_sdk/Package.swift` (the only iOS pin; there is no podspec since 19.0.0, see below) and `io.gleap:gleap-android-sdk` in `android/build.gradle`. The iOS tag `X.Y.Z` must exist on GleapSDK/Gleap-iOS-SDK before this release is tagged, or apps can't resolve the package.
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

## iOS (Swift Package Manager only)

The iOS side is a Swift package at `ios/gleap_sdk/` (layout from [Swift Package Manager for plugin authors](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-plugin-authors)): `Package.swift`, the public header in `Sources/gleap_sdk/include/gleap_sdk/`, the implementation in `Sources/gleap_sdk/`. It depends on the `FlutterFramework` package the Flutter tool generates (Flutter 3.41+) and on the `Gleap` product of GleapSDK/Gleap-iOS-SDK. There is no podspec: CocoaPods trunk becomes read-only on 2026-12-02, and a plugin podspec can only name the `Gleap` pod, which CocoaPods resolves from trunk unless every app overrides it in its own Podfile.

Both `pubspec.yaml` files set `config: enable-swift-package-manager: true`, so the example works on Flutter 3.41–3.43 without a global `flutter config` (3.44+ has it on by default). The example app has no Podfile.

Building the example for the simulator (`flutter build ios --simulator` fails on engines without an x86_64 slice):

```sh
cd example && flutter pub get && flutter build ios --config-only --simulator --debug
cd ios && xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' ARCHS=arm64 build
```

Before the Gleap iOS tag of a new version exists, point `Package.swift` at `branch: "main"` (or `path:` to a local checkout) for the build only, and commit `from: "X.Y.Z"`.
