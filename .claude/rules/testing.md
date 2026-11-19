---
paths:
  - "**/*.dart"
  - "android/**"
  - "ios/**"
---

# Testing

Tests come first and stay fixed while the code is written: an agent that may change a test will change it to get green.

- **New behaviour or a bug fix:** write the test first, from the requirement and not from the code. Use the `test-writer` subagent if you can start one. See it fail for the expected reason, then write the code without touching it.
- **Refactor without a behaviour change:** tests stay unchanged. Nothing covers the code? Pin today's behaviour with a test first.
- **Never edit, skip or delete an existing test to make a change pass,** and never detect test inputs or hardcode answers. No `skip:`, retries or delays to make a test pass. If a test looks wrong, stop and report `BLOCKED` with the reason. A test changes only when the required behaviour changed; say so in the PR.

## What needs what

| Code | Test |
|---|---|
| A decision: the arguments a call sends, which Project ID wins, a token answer, redaction, the log buffer | a unit test in `test/<area>_test.dart` that calls the function directly (`test/gleap_identity_helper_test.dart`) |
| A `Gleap.*` method | move what it decides into a function under `lib/` and test that; the method itself returns early on the test host (`dart:io` checks) |
| Dart code that runs on the test host and calls the channel | mock the channel with `TestDefaultBinaryMessengerBinding` (below) and assert the `MethodCall`s it sent |
| A callback from native code | a function the handler calls (as `gleapAnswerUserJwtRequest`), tested with the arguments Android and iOS send (a JSON string and a map) |
| A widget (`GleapBannerArea`) | `testWidgets` with the notifier it listens to |
| A new channel method, a platform it skips, a new callback | `test/gleap_channel_parity_test.dart` stays green, its lists updated |
| The web implementation | it needs a browser (`flutter test --platform chrome`), which is not set up: keep the logic in plain Dart functions and test those; say what you checked by hand |
| Java or Objective-C | there are no native unit tests yet: build the example for that platform (CONTRIBUTING.md) and say what you verified and how |

Every new path that can drop or delay something gets a test: a call before `initialize`, a provider that throws or returns nothing, an entry over the size limit, a platform that does not support the call.

## How tests are written

- `flutter_test` only; a mocking or async helper package needs asking first (it changes `pubspec.yaml`, which ships). Test names state the behaviour: `'answer null without a provider, on an error or without a token'`.
- `group` per unit, `test` per behaviour, plain `expect` with matchers. Failure `reason:` says what was wanted when the matcher alone does not.
- State the SDK keeps in statics (`@visibleForTesting` hooks such as `Gleap.debugClearNetworkLogs`) is reset in `tearDown` or `addTearDown`.
- The channel mock, removed after the test:

  ```dart
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel channel = MethodChannel('gleap_sdk');
  final List<MethodCall> calls = <MethodCall>[];
  final TestDefaultBinaryMessenger messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
    calls.add(call);
    return null;
  });
  addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
  ```

- No real network, no real native SDK, no sleeps. Time in widget tests moves with `tester.pump(duration)`.
- Assert what the app or the native side gets (the `MethodCall`, the returned value, the redacted entry), not that a line ran.

## What to run

- While you work: `flutter test test/<file>_test.dart`, or `flutter test --plain-name '<name>'`.
- Before you finish: `sh tool/check_new.sh`, `flutter test`, and for Android or iOS changes the example build for that platform.
- CI runs `flutter test --coverage` with a floor on `lib/` (`COVERAGE_FLOOR` in `.github/workflows/ci.yml`). Raise it when coverage rises; never lower it without saying why in the PR.

If no test reaches the code you changed, that is not a pass: say in your report what no test covered.
