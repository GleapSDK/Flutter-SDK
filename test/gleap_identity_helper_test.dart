import 'package:flutter_test/flutter_test.dart';
import 'package:gleap_sdk/helpers/gleap_identity_helper.dart';
import 'package:gleap_sdk/models/gleap_user_property_model/gleap_user_property_model.dart';

void main() {
  group('identify arguments', () {
    test('keep the user hash without user properties', () {
      expect(
        gleapIdentifyArguments(userId: 'user-1', userHash: 'a.b.c'),
        <String, dynamic>{'userId': 'user-1', 'userHash': 'a.b.c'},
      );
    });

    test('send properties and hash together', () {
      final Map<String, dynamic> arguments = gleapIdentifyArguments(
        userId: 'user-1',
        userProperties: GleapUserProperty(name: 'Ada'),
        userHash: 'hash',
      );
      expect(arguments['userId'], 'user-1');
      expect(arguments['userHash'], 'hash');
      expect(arguments['userProperties'], isA<Map<String, dynamic>>());
    });

    test('leave out what is not set', () {
      expect(
        gleapIdentifyArguments(userId: 'user-1'),
        <String, dynamic>{'userId': 'user-1'},
      );
    });
  });

  group('token requests', () {
    test('answer with the provider token', () async {
      expect(await gleapAnswerUserJwtRequest(() async => 'fresh.jwt.token'),
          'fresh.jwt.token');
      expect(await gleapAnswerUserJwtRequest(() => 'sync.jwt.token'),
          'sync.jwt.token');
    });

    test('answer null without a provider, on an error or without a token',
        () async {
      expect(await gleapAnswerUserJwtRequest(null), isNull);
      expect(
          await gleapAnswerUserJwtRequest(
              () async => throw Exception('offline')),
          isNull);
      expect(await gleapAnswerUserJwtRequest(() async => null), isNull);
      expect(await gleapAnswerUserJwtRequest(() async => ''), isNull);
    });
  });
}
