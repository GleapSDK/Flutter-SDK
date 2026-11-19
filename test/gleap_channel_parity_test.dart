// The Dart API and the three platform implementations meet only on the
// 'gleap_sdk' method channel, by method name. A name that one side misspells
// or forgets fails silently in a customer's app (a MissingPluginException the
// SDK swallows, or a callback that never comes), and no unit test reaches the
// native code. These tests read the sources and compare the names.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const String _dartApi = 'lib/gleap_sdk.dart';
const String _web = 'lib/gleap_sdk_web.dart';
const String _android =
    'android/src/main/java/io/gleap/gleap_sdk/GleapSdkPlugin.java';
const String _ios = 'ios/gleap_sdk/Sources/gleap_sdk/GleapSdkPlugin.m';

/// Methods the Dart API sends only on some platforms (it checks the platform
/// before the call, and the DartDoc's "Available Platforms" says so). A new
/// gap needs that check and that line in the DartDoc, and an entry here.
const Map<String, Set<String>> _notHandledOn = <String, Set<String>>{
  'Android': <String>{
    'enableDebugConsoleLog',
    'startNetworkLogging',
    'stopNetworkLogging',
  },
  'iOS': <String>{},
  'Web': <String>{
    'addAttachment',
    'enableDebugConsoleLog',
    'getBannerHeight',
    'handlePushNotification',
    'removeAllAttachments',
    'setActivationMethods',
  },
};

/// Callbacks Android and iOS send to Dart that the web implementation does
/// not send.
const Set<String> _notSentByWeb = <String>{
  'bannerHeightChanged',
  'flushLogs',
  'notificationCountUpdated',
};

String _read(String path) => File(path).readAsStringSync();

Set<String> _names(String source, String pattern) => RegExp(pattern)
    .allMatches(source)
    .map((RegExpMatch match) => match.group(1)!)
    .toSet();

/// Method names the Dart API invokes on the channel.
Set<String> _sentByDart() =>
    _names(_read(_dartApi), r"""invokeMethod(?:<[^>]*>)?\(\s*'(\w+)'""");

/// The `case` labels of Android's `switch (call.method)`, at that switch's
/// own indentation: nested switches on an argument (a survey format) have
/// labels too.
Set<String> _androidHandled() {
  final String source = _read(_android);
  final String indent = RegExp(r'switch \(call\.method\) \{\n([ \t]*)case "')
      .firstMatch(source)!
      .group(1)!;
  return _names(source, '(?:^|\\n)$indent' r'case "(\w+)":');
}

/// Method names each platform answers.
Map<String, Set<String>> _handled() => <String, Set<String>>{
      'Android': _androidHandled(),
      'iOS': _names(_read(_ios), r'\[@"(\w+)" isEqualToString:call\.method\]'),
      'Web': _names(_read(_web), r"case '(\w+)':"),
    };

/// Callback names each platform sends to Dart.
Map<String, Set<String>> _sentToDart() => <String, Set<String>>{
      'Android': _names(_read(_android), r'invokeMethod\("(\w+)"'),
      'iOS': _names(_read(_ios), r'invokeMethod:@"(\w+)"'),
      'Web': _names(_read(_web), r"""invokeMethod(?:<[^>]*>)?\(\s*'(\w+)'"""),
    };

void main() {
  test('every platform opens the channel under the same name', () {
    expect(_read(_dartApi), contains("MethodChannel('gleap_sdk')"));
    expect(_read(_web), contains("'gleap_sdk',"));
    expect(_read(_android), contains('"gleap_sdk")'));
    expect(_read(_ios), contains('methodChannelWithName:@"gleap_sdk"'));
  });

  test('the sources are where these tests look for them', () {
    expect(_sentByDart(), hasLength(greaterThan(50)));
    for (final MapEntry<String, Set<String>> platform in _handled().entries) {
      expect(platform.value, hasLength(greaterThan(50)),
          reason: '${platform.key} handlers not found');
    }
  });

  test('every method the Dart API sends is handled on every platform', () {
    final Set<String> sent = _sentByDart();
    for (final MapEntry<String, Set<String>> platform in _handled().entries) {
      expect(
        sent.difference(platform.value),
        _notHandledOn[platform.key],
        reason: 'Methods ${platform.key} does not handle. Implement them '
            'there, or, if the Dart API skips that platform, add them to '
            '_notHandledOn. An entry that is handled now leaves the list.',
      );
    }
  });

  test('no platform handles a method the Dart API never sends', () {
    final Set<String> sent = _sentByDart();
    for (final MapEntry<String, Set<String>> platform in _handled().entries) {
      expect(platform.value.difference(sent), isEmpty,
          reason: '${platform.key} handles a name Dart never sends: a typo, '
              'or a method the Dart API lost');
    }
  });

  test('Android and iOS send Dart the same callbacks, web a known subset', () {
    final Map<String, Set<String>> sent = _sentToDart();
    expect(sent['Android'], hasLength(greaterThan(10)));
    expect(sent['iOS'], sent['Android']);
    expect(sent['Web']!.difference(sent['Android']!), isEmpty,
        reason: 'The web implementation sends a callback the apps never get');
    expect(sent['Android']!.difference(sent['Web']!), _notSentByWeb);
  });
}
