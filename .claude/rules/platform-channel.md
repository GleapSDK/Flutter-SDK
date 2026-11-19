---
paths:
  - "lib/**/*.dart"
  - "android/**"
  - "ios/**"
  - "test/gleap_channel_parity_test.dart"
---

# Public API and the platform channel

The Dart API, the Android plugin, the iOS plugin and the web implementation meet only on the `gleap_sdk` method channel, by method name and argument keys. Nothing compiles one side against another: a misspelt name is a call that silently does nothing in a customer's app. `test/gleap_channel_parity_test.dart` compares the names; keys and types are on you and the review.

## One call, four places

A new `Gleap.*` method that talks to the native SDK lands in one PR:

1. The Dart method in `lib/gleap_sdk.dart`: DartDoc with `**Available Platforms**`, the platform check, arguments built by a tested function, the channel call.
2. A `case` in `GleapSdkPlugin.java`'s `switch (call.method)`.
3. A branch in `GleapSdkPlugin.m`'s `handleMethodCall`.
4. A `case` in `GleapSdkWeb.handleMethodCall` that calls a binding in `lib/helpers/gleap_js_sdk_helper.dart`.

A platform the native SDK does not support is skipped in Dart before the call (with `debugPrint('… is not available for current operating system')`, as the existing methods do), named in the DartDoc's platforms, and listed in `_notHandledOn` in the parity test. Never leave a platform to answer `notImplemented`.

The same holds the other way: a callback the native SDKs send to Dart is sent under the same name by Android and iOS, and by the web unless the parity test lists it in `_notSentByWeb`.

## The wire

- **Names and keys change only on all sides at once**, in one PR, with the parity test green. The Dart and native halves ship together in one package version, but the native SDK pins (`android/build.gradle`, `ios/gleap_sdk.podspec`, `ios/gleap_sdk/Package.swift`) move on their own schedule: a call must work with the pinned native version.
- **Types are what `StandardMessageCodec` carries:** `null`, `bool`, `int`, `double`, `String`, typed lists, `List` and `Map` of those. No `DateTime` (send ISO-8601 strings or milliseconds), no enums (send the wire string from a `switch`), no custom objects (send `toJson()`).
- **Optional arguments that are not set are left out**, not sent as `null`, as `gleapIdentifyArguments` does. The native side still checks for a missing key, `null` and `NSNull`.
- **Callback arguments:** Android sends JSON strings and iOS maps for the old listeners (`_initCallbackHandler` decodes on Android). A new callback sends a map from both.
- **Answers:** a call returns `null` or a codec value; the native side answers once (`.claude/rules/code-conventions.md`, Android and iOS).

## Public API

- Every public name under `lib/` is API (there is no `lib/src/` yet). Never remove, rename or change the meaning of one in a minor or patch version; add optional named parameters and new methods instead.
- Deprecate with `@Deprecated('Use X …')`, keep the behaviour, say so in `CHANGELOG.md`. Removal is a major version: stop and ask.
- A new call updates its DartDoc, `CHANGELOG.md` and, for a new feature, `README.md` in the same PR.
- New behaviour is opted into; an app that updates the SDK and changes nothing keeps today's behaviour.
- Minimum versions are API too: Dart `>=3.3.0` (it also fixes the language features and the formatter style), Flutter `>=3.19.0`, iOS 15, Android minSdk 21. Raising one drops apps: stop and ask.

## Identity and privacy

- Identity tokens (`setUserJwt`, `setUserJwtProvider`, `setAuthTokens`, `identify`'s `userHash`) cross the channel and nowhere else: never logged, printed, kept in Dart beyond the call, or put in an error.
- A token request from the native side (`requestUserJwt`) answers `null` on any failure (`gleapAnswerUserJwtRequest`): the native SDK then goes on without one. Never throw back.
- Network log entries leave Dart only through `GleapNetworkLogStore`, which redacts them (`GleapNetworkLogRedaction`). A new field in an entry is redacted or left out before it is added.

## Web

- `window.Gleap` comes from the script tag the app adds (README → Web installation). Bindings are `@JS` externals with `dart:js_interop` types (`JSString`, `JSAny`, `JSPromise`); convert with `.toJS` / `.toDart` at the call, and await a `JSPromise` with `.toDart`.
- The web side answers every Dart method that is not listed in `_notHandledOn['Web']`, even if only with `null`.
