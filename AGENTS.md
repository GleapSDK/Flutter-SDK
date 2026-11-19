# Gleap Flutter SDK

`gleap_sdk` on pub.dev: the Flutter plugin apps add for Gleap's support chat, bug reports, surveys, banners, tours and network logs. A Dart API over the native Gleap SDKs: `io.gleap:gleap-android-sdk` on Android, `Gleap` from GleapSDK/Gleap-iOS-SDK on iOS, and on the web the Gleap JavaScript SDK the app's `index.html` loads.

- `lib/gleap_sdk.dart`: the public API, static methods on `Gleap` (about 2,300 lines). Every call goes over one `MethodChannel('gleap_sdk')`. The native side calls back over the same channel (`_initCallbackHandler`: listeners, identity token requests, banner height, log flushes).
- `lib/gleap_sdk_web.dart`: the web implementation `GleapSdkWeb` (registered in `pubspec.yaml`). It answers the same channel by calling `window.Gleap` through `dart:js_interop` (`lib/helpers/gleap_js_sdk_helper.dart`).
- `lib/helpers/`: pure Dart pieces with tests: identify and initialize arguments, identity token requests, the network log store and its redaction. `lib/models/`: `json_serializable` models with generated `*.g.dart`. `lib/widgets/gleap_banner_area.dart`.
- `android/`: `GleapSdkPlugin.java`, Java 8 source level, one `switch (call.method)`. No Kotlin.
- `ios/`: `GleapSdkPlugin.m` (Objective-C) in the Swift package `ios/gleap_sdk/` (`Package.swift`) and, for CocoaPods apps, `ios/gleap_sdk.podspec` over the same sources (CONTRIBUTING.md → iOS).
- `example/`: the demo app. It is published with the package as its example.

How it ships: a version tag `X.Y.Z` runs `.github/workflows/release.yml`, which publishes to pub.dev and creates the GitHub Release (CONTRIBUTING.md → Releasing). Apps pin versions, so an old SDK stays in apps for years. pub.dev gets every file that is not hidden and not in `.pubignore`: `lib/`, `android/`, `ios/`, `example/`, `test/`, the Markdown files, `LICENSE`, `pubspec.yaml`, `analysis_options.yaml`. `AGENTS.md`, `CLAUDE.md` and `tool/` stay out (`.pubignore`).

Terms: the Project ID is the project's key (formerly SDK key or `token`), a conversation is a ticket, a contact (session) is the app's end user.

## Commands

```bash
flutter pub get                    # once per worktree; resolves example/ too
sh .githooks/install.sh            # once per clone: git push runs tool/check_new.sh
sh tool/check_new.sh               # analyzer and format on what this branch adds compared with origin/main
flutter analyze --no-fatal-infos   # the whole repo, as CI and release.yml run it: warnings and errors fail
flutter test                       # unit tests: seconds, no device, no network
flutter test test/gleap_channel_parity_test.dart           # one file
flutter test --plain-name 'resolves projectId first'        # one test
flutter test --coverage            # what CI runs; CI holds a floor (ci.yml, COVERAGE_FLOOR)
flutter pub publish --dry-run      # validates the package and lists the files pub.dev would get
```

`flutter analyze` lists about 360 infos in old code (missing docs, dynamic calls). They are expected; `tool/check_new.sh` fails on any issue in lines the branch adds.

Use the Dart SDK inside Flutter: `DART="$(dirname "$(command -v flutter)")/dart"`, then `"$DART" format <file>`, or after changing a model in `lib/models/`, `"$DART" run build_runner build --delete-conflicting-outputs`. A standalone `dart` earlier on the PATH can be years older and analyzes and formats differently. `tool/check_new.sh` and the hooks pick the right one.

CI (`.github/workflows/ci.yml`) runs `flutter analyze --no-fatal-infos`, `flutter test --coverage` with its floor and `flutter pub publish --dry-run` on every PR and push to `main`. `.github/workflows/quality.yml` runs `tool/check_new.sh` on PRs with the base branch's copy of it and of `analysis_options.yaml`. Both use Flutter 3.41.4, the version `release.yml` publishes with. CI does not compile the Java or Objective-C code.

Done means `sh tool/check_new.sh` and `flutter test` pass, `flutter analyze --no-fatal-infos` reports no warning or error, and CI is green. A change to Android or iOS code is also built in the example for that platform (CONTRIBUTING.md), or you say that you could not. Say which commands you ran and what they printed.

A Flutter other than 3.41.4 rewrites `pubspec.lock` and `example/pubspec.lock` (Flutter pins `meta`, `test_api` and others). Leave that out of commits unless you changed a dependency on purpose: `git checkout -- pubspec.lock example/pubspec.lock`. The hooks run `flutter test --no-pub` so they do not touch them.

New worktree: `flutter pub get`, and once per clone `sh .githooks/install.sh`. The repo has no `.env` and no secrets.

`git push` runs `tool/check_new.sh` on your branch (`.githooks/pre-push`). Agents fix what it reports and push again; they never use `--no-verify`.

## Code

New files and the code you change follow `.claude/rules/code-conventions.md`, the API and the channel follow `.claude/rules/platform-channel.md`, and tests follow `.claude/rules/testing.md`. Read them before your first edit: old code here is no precedent.

## Public API

Everything an app can call or rely on is public: every public name in every library under `lib/` (there is no `lib/src/`, so `package:gleap_sdk/helpers/…` and `…/models/…` are importable too), its parameters, defaults, enum values, callbacks and listener names, and the minimum versions (`sdk: >=3.3.0`, `flutter: >=3.19.0`, iOS 15, Android minSdk 21).

- **Never remove, rename or change the meaning of any of it in a minor or patch version.** Add instead: a new optional named parameter, a new method.
- **Deprecate, don't delete:** `@Deprecated('Use projectId. The value is the same.')` with what to use instead, the behaviour kept, and a line in `CHANGELOG.md` (as `Gleap.initialize`'s `token:`). Removal needs a major version: stop and ask.
- **A change to the API updates the DartDoc (with its `**Available Platforms**`), `CHANGELOG.md` and, for a new feature, `README.md` in the same PR.**
- **New behaviour is opted into** by a new call or a dashboard setting, never by updating the SDK.
- **New internal code goes in `lib/src/`**, which apps are not meant to import, or is private (`_name`).

## Security and privacy

- **Identity tokens are the end user's credentials:** `setUserJwt`, `setUserJwtProvider`, `setAuthTokens` and `identify`'s `userHash`. Never log, print or put them in an error or a callback argument.
- **Network logs are redacted before they leave Dart:** every entry goes through `GleapNetworkLogStore` and `GleapNetworkLogRedaction` (`lib/helpers/`): `authorization`, `proxy-authorization`, `cookie` and `set-cookie` are masked, `gleap.io` / `gleap.ai` requests are dropped, configured props are removed. A new way to collect logs uses the store.
- `debugPrint` says that a call is not available on this platform; it never prints user data.
- The repo is public: no customer's project ID, user data, name or domain in code, tests, docs or commits. The example's Project ID is the demo project's.
- Publishing uses pub.dev's automated publishing (GitHub OIDC); no token belongs in this repo.

## Traps

- **Most `Gleap.*` methods do nothing in `flutter test`:** they return early unless `dart:io`'s `Platform` is Android or iOS, so a mocked channel never sees their calls. Test the function that builds the arguments (`gleapIdentifyArguments`). New code checks `kIsWeb` and `defaultTargetPlatform`, which tests can set with `debugDefaultTargetPlatformOverride`; `dart:io` also keeps the package from being WASM-ready on pub.dev.
- **Android sends callback arguments as JSON strings, iOS as maps:** `_initCallbackHandler` decodes them on Android only.
- **A release changes the version in five places** (CONTRIBUTING.md → Releasing), and the Gleap iOS tag must exist before the Flutter tag.
- **Methods missing on a platform are on purpose**, guarded in Dart: `test/gleap_channel_parity_test.dart` lists them (`_notHandledOn`).
- **Flutter 3.50 deprecates `package:flutter/material.dart`** (pub.dev reports it as an info). Moving to `material_ui` raises the Flutter minimum: stop and ask.
- **`*.g.dart` are generated:** change the model and run build_runner, never edit them by hand.
- **The example is behind:** `example/test/widget_test.dart` is the old template and fails. The Android example does not build with Flutter 3.44 or later (its Android Gradle Plugin 8.3.2 is below Flutter's minimum 8.6.0), and a newer Flutter writes `android.newDsl=false` and `android.builtInKotlin=false` into `example/android/gradle.properties`: leave that out of commits. Fixing the example is a change of its own; it ships in the package.
- **Seven Dart files are not `dart format`-clean** (`lib/gleap_sdk.dart`, `lib/gleap_sdk_web.dart`, three helpers, two tests). `tool/check_new.sh` leaves them alone; do not reformat them in a feature PR.
- **`analysis_options.yaml` and `pubspec.yaml` ship in the package.** Never raise a lint severity or turn on a strict mode: old code would fail release.yml's analyze step, and a raised severity also costs pub.dev points (pub.dev's analysis takes over the `errors:` section).
- `pubspec.yaml`'s `config: enable-swift-package-manager: true` only affects this repo, not apps. `.idea/` and `gleap_sdk.iml` are committed IDE files, and `gleap_sdk.iml` is published.

## Tests

New behaviour and bug fixes start with a test that fails; refactors leave tests unchanged. Full rules: `.claude/rules/testing.md`.

- `flutter_test` only, `test/<area>_test.dart`, `group` and `test` with names that state the behaviour. No mocking library without asking.
- Decisions go in pure functions under `lib/` and are tested directly. The channel is mocked with `TestDefaultBinaryMessengerBinding` only for code that runs on the test host.
- A new channel method, or one a platform skips, keeps `test/gleap_channel_parity_test.dart` green.
- Never edit, skip or delete an existing test to make a change pass. If one looks wrong, stop and report `BLOCKED` with the reason.

## Customer requests

A ticket is one customer's view. A bug report: first check whether the code does something other than intended; if it works as designed, change nothing and say what the customer can do instead. Never special-case one customer in code: no project, organisation or user ids, names or domains in conditions. If the only fix that works is specific to one customer, stop and ask.

## Stop and ask

Keep going while a step needs no input. Stop and ask before: tagging or publishing (`git tag`, `flutter pub publish` without `--dry-run`), a version bump, raising a minimum version (Dart, Flutter, iOS, Android), adding or changing a dependency (a runtime one is resolved in every customer's app), changing a native SDK pin, removing or changing anything public (above), renaming the channel, a method name or an argument key, changing `release.yml`, or raising a severity in `analysis_options.yaml`.

## Production

Merging to `main` ships nothing. A human pushes the version tag (CONTRIBUTING.md → Releasing) and `release.yml` publishes it. A published version cannot be changed or deleted: a broken release is fixed by a new version, and a human can retract it on pub.dev within seven days.
