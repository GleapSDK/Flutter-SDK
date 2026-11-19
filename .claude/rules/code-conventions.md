---
paths:
  - "**/*.dart"
  - "android/**"
  - "ios/**"
---

# Code conventions

For new files and the code you change; do not rewrite other code to match. Copy the examples below, not your neighbours: `lib/gleap_sdk.dart` and `lib/gleap_sdk_web.dart` are far over every limit, and much old code passes `dynamic` around. `sh tool/check_new.sh` checks the mechanical part on what your branch adds (`analysis_options.yaml`, `dart format`); the rest is on you and the review.

Sources: [Effective Dart](https://dart.dev/effective-dart), [Dart package layout](https://dart.dev/tools/pub/package-layout), [Developing plugins](https://docs.flutter.dev/packages-and-plugins/developing-packages), [Platform channels](https://docs.flutter.dev/platform-integration/platform-channels).

## Dart

- **Size:** aim for files under 400 lines and never write a new one over 700; functions under 60 lines. `Gleap` in `lib/gleap_sdk.dart` keeps one static method per API call, and that method stays thin: platform check, arguments from a tested function, the channel call. Logic goes in its own file under `lib/src/` (or `lib/helpers/`, as today) with its test.
- **Types:** no `dynamic` in a new signature. What comes from the channel or from JS is typed at the boundary: `invokeMethod<T>`, maps as `Map<Object?, Object?>` and converted with `Map<String, Object?>.from` after a type check. Never call a method on a `dynamic` (`avoid_dynamic_calls`).
- **Futures:** await them, or wrap them in `unawaited(...)` with a comment why the caller does not wait. A dropped future hides its error.
- **Errors:** the SDK never crashes the app. A channel call that a platform cannot answer is caught at the boundary (`on PlatformException`, `on MissingPluginException`); a catch-all says in a comment why. Throw only for a caller's mistake that the DartDoc names (`ArgumentError` in `initialize`).
- **Platform checks:** `kIsWeb` and `defaultTargetPlatform` from `package:flutter/foundation.dart`, not `dart:io`'s `Platform`: tests can set `debugDefaultTargetPlatformOverride`, and `dart:io` keeps the package from WASM.
- **Names:** Effective Dart: `UpperCamelCase` types, `lowerCamelCase` members and enum values, `snake_case.dart` files. The old enums (`Severity.LOW`) are public API and stay. A value that crosses the channel is mapped by a `switch` to its wire string, never by `.name`, so renaming a value cannot change the wire.
- **Docs:** `///` on every public member (`public_member_api_docs`), with the same shape as the existing methods: what it does, a code sample for a new call, the parameters, and `**Available Platforms**`.
- **Imports:** `package:gleap_sdk/...`, never relative (`always_use_package_imports`).
- **Comments:** why, in English, one or two lines. No ticket or PR numbers, people's names, customer names, dates or decision histories: those belong in the PR.
- **Dependencies:** no new package in `pubspec.yaml` without asking. A runtime dependency is resolved in every customer's app and can conflict with theirs.

## Android (Java)

- Java 8 source level (`android/build.gradle`), minSdk 21: no newer Java or Android APIs without a version check.
- Every call answers `result` exactly once: `success`, `error` with a code and message, or `notImplemented` for an unknown method (the `default:` branch).
- Calls into the native SDK and `channel.invokeMethod` run on the main thread: post to `uiThreadHandler` as `requestLogFlush` does.
- Arguments may be missing or `null`, and integers arrive as `Integer` or `Long`: check before casting.

## iOS (Objective-C)

- Every branch of `handleMethodCall` calls `result` exactly once; an unknown method gets `FlutterMethodNotImplemented`.
- Arguments may be missing or `NSNull`: check before use.
- UI and channel calls on the main queue (`dispatch_async(dispatch_get_main_queue(), …)`), blocks capture `self` weakly.
- Gleap is imported as `<Gleap/Gleap.h>` under CocoaPods and `@import Gleap` under Swift Package Manager: keep both paths when touching imports.

## One job, one system

| Job | Use | Not in new code |
|---|---|---|
| Dart to native | `Gleap._channel` (`MethodChannel('gleap_sdk')`) | a second channel, pigeon, an event channel without asking |
| Native to Dart | `_initCallbackHandler` and the `CallbackItem` listeners | a handler set elsewhere |
| Web | `lib/gleap_sdk_web.dart` and `dart:js_interop` bindings in `lib/helpers/gleap_js_sdk_helper.dart` | `dart:html`, `package:js`, `dart:js` |
| Network logs | `GleapNetworkLogStore` and `GleapNetworkLogRedaction` | a list of entries kept elsewhere |
| JSON models | `json_serializable` with generated `*.g.dart` | hand-written `toJson` next to a generated one |
| Logging | `debugPrint`, without user data | `print` in `lib/` |
| Tests | `flutter_test` | mockito, mocktail and other packages without asking |

## Examples to copy

- A pure function the API calls, and its test: `lib/helpers/gleap_identity_helper.dart`, `test/gleap_identity_helper_test.dart`.
- Input from outside, handled without throwing and documented: `lib/helpers/gleap_network_log_redaction.dart`.
- A small widget on a `ValueListenable`: `lib/widgets/gleap_banner_area.dart`.
