# Contributing

## Releasing

Releases are published to [pub.dev](https://pub.dev/packages/gleap_sdk) by GitHub Actions ([`.github/workflows/release.yml`](.github/workflows/release.yml)) when a version tag is pushed. The tag is the plain version (`18.2.0`, no `v`), the same across all Gleap SDKs. Nobody runs `flutter pub publish` by hand.

1. In a PR, bump the version:
   - `version` in `pubspec.yaml`
   - the native pins: `s.dependency 'Gleap', 'X.Y.Z'` in `ios/gleap_sdk.podspec`, `from: "X.Y.Z"` in `ios/gleap_sdk/Package.swift` and `io.gleap:gleap-android-sdk` in `android/build.gradle`
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
