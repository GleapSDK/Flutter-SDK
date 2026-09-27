import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gleap_sdk/helpers/gleap_network_log_redaction.dart';
import 'package:gleap_sdk/helpers/gleap_network_log_store.dart';

Map<String, dynamic> entry({
  String url = 'https://api.example.com/v1/items',
  Map<String, dynamic>? requestHeaders,
  String payload = '',
  Map<String, dynamic>? responseHeaders,
  String? responseText,
}) {
  return <String, dynamic>{
    'type': 'POST',
    'url': url,
    'date': '2026-09-27T10:00:00.123Z',
    'duration': 12,
    'success': true,
    'request': <String, dynamic>{
      'headers': requestHeaders ?? <String, dynamic>{},
      'payload': payload,
    },
    'response': <String, dynamic>{
      'status': 200,
      'statusText': 'OK',
      'headers': responseHeaders ?? <String, dynamic>{},
      if (responseText != null) 'responseText': responseText,
    },
  };
}

Map<String, dynamic> redact(
  Map<String, dynamic> input, {
  List<String> props = const <String>[],
  List<String> blacklist = const <String>[],
}) {
  final Map<String, dynamic>? result = GleapNetworkLogRedaction.redactEntry(
    input,
    propsToIgnore: props,
    blacklist: blacklist,
  );
  expect(result, isNotNull);
  return result!;
}

void main() {
  group('blacklist', () {
    test('always drops gleap.io and gleap.ai urls, case-insensitive', () {
      for (final String url in <String>[
        'https://api.gleap.io/bugs/v2',
        'https://API.GLEAP.AI/sessions',
        'wss://ws.gleap.io/',
      ]) {
        expect(
          GleapNetworkLogRedaction.redactEntry(entry(url: url)),
          isNull,
          reason: url,
        );
      }
    });

    test('drops urls containing a configured entry', () {
      expect(
        GleapNetworkLogRedaction.redactEntry(
          entry(url: 'https://api.example.com/v1/secret/tokens'),
          blacklist: <String>['/secret/'],
        ),
        isNull,
      );
      expect(
        GleapNetworkLogRedaction.redactEntry(
          entry(url: 'https://api.example.com/v1/items'),
          blacklist: <String>['/secret/'],
        ),
        isNotNull,
      );
    });

    test('redactEntries keeps the order and removes blacklisted entries', () {
      final List<Map<String, dynamic>> result =
          GleapNetworkLogRedaction.redactEntries(
        <Map<String, dynamic>>[
          entry(url: 'https://a.example.com/1'),
          entry(url: 'https://api.gleap.io/x'),
          entry(url: 'https://b.example.com/2'),
        ],
      );
      expect(
        result.map((Map<String, dynamic> e) => e['url']),
        <String>['https://a.example.com/1', 'https://b.example.com/2'],
      );
    });
  });

  group('headers', () {
    test('always masks credential headers on request and response', () {
      final Map<String, dynamic> result = redact(entry(
        requestHeaders: <String, dynamic>{
          'Authorization': 'Bearer abc',
          'proxy-authorization': 'Basic xyz',
          'COOKIE': 'sid=1',
          'Accept': 'application/json',
        },
        responseHeaders: <String, dynamic>{
          'Set-Cookie': 'sid=2; HttpOnly',
          'Content-Type': 'application/json',
        },
      ));

      expect(result['request']['headers'], <String, dynamic>{
        'Authorization': '[REDACTED]',
        'proxy-authorization': '[REDACTED]',
        'COOKIE': '[REDACTED]',
        'Accept': 'application/json',
      });
      expect(result['response']['headers'], <String, dynamic>{
        'Set-Cookie': '[REDACTED]',
        'Content-Type': 'application/json',
      });
    });

    test('removes headers named like a prop, case-insensitive', () {
      final Map<String, dynamic> result = redact(
        entry(
          requestHeaders: <String, dynamic>{
            'X-Api-Key': 'k1',
            'Accept': '*/*',
          },
          responseHeaders: <String, dynamic>{
            'x-api-key': 'k2',
            'X-Request-Id': 'r1',
          },
        ),
        props: <String>['x-API-key'],
      );

      expect(result['request']['headers'], <String, dynamic>{'Accept': '*/*'});
      expect(
        result['response']['headers'],
        <String, dynamic>{'X-Request-Id': 'r1'},
      );
    });
  });

  group('JSON bodies', () {
    test('removes matching keys at any depth, also inside arrays', () {
      final Map<String, dynamic> result = redact(
        entry(
          payload: jsonEncode(<String, dynamic>{
            'Password': 'p1',
            'name': 'a',
            'nested': <String, dynamic>{
              'password': 'p2',
              'list': <dynamic>[
                <String, dynamic>{'PASSWORD': 'p3', 'keep': 1},
                'password',
              ],
            },
          }),
          responseText: '[{"token":"t1","id":1},{"id":2,"deep":{"Token":"t2"}}]',
        ),
        props: <String>['password', 'TOKEN'],
      );

      expect(
        result['request']['payload'],
        '{"name":"a","nested":{"list":[{"keep":1},"password"]}}',
      );
      expect(result['response']['responseText'], '[{"id":1},{"id":2,"deep":{}}]');
    });

    test('a dotted prop is a path from the root and a whole key', () {
      final Map<String, dynamic> result = redact(
        entry(
          payload: jsonEncode(<String, dynamic>{
            'User': <String, dynamic>{'Password': 'p1', 'name': 'a'},
            'other': <String, dynamic>{'password': 'kept'},
            'user.password': 'p2',
            'items': <dynamic>[
              <String, dynamic>{'user.PASSWORD': 'p3', 'id': 1},
            ],
          }),
          responseText: jsonEncode(<dynamic>[
            <String, dynamic>{
              'user': <String, dynamic>{'password': 'p4', 'id': 7},
            },
          ]),
        ),
        props: <String>['user.password'],
      );

      expect(
        jsonDecode(result['request']['payload'] as String),
        <String, dynamic>{
          'User': <String, dynamic>{'name': 'a'},
          'other': <String, dynamic>{'password': 'kept'},
          'items': <dynamic>[
            <String, dynamic>{'id': 1},
          ],
        },
      );
      expect(result['response']['responseText'], '[{"user":{"id":7}}]');
    });

    test('leaves unparseable (truncated) and unchanged bodies untouched', () {
      const String truncated = '{"password":"p1","data":"aaaa\n… [truncated, '
          '200000 bytes]';
      const String unchanged = '{ "name": "a",\n  "list": [1, 2] }';
      final Map<String, dynamic> result = redact(
        entry(payload: truncated, responseText: unchanged),
        props: <String>['password'],
      );

      expect(result['request']['payload'], truncated);
      expect(result['response']['responseText'], same(unchanged));
    });

    test('does not double-encode plain text or JSON scalars', () {
      final Map<String, dynamic> result = redact(
        entry(payload: '"password"', responseText: 'password=1'),
        props: <String>['password'],
      );

      expect(result['request']['payload'], '"password"');
      expect(result['response']['responseText'], 'password=1');
    });
  });

  group('form bodies and query params', () {
    test('removes form fields named like a prop, case-insensitive', () {
      final Map<String, dynamic> result = redact(
        entry(
          requestHeaders: <String, dynamic>{
            'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
          },
          payload: 'username=alice&Pass%77ord=s3cret&remember=1',
          responseHeaders: <String, dynamic>{
            'content-type': 'application/x-www-form-urlencoded',
          },
          responseText: 'access_token=abc&expires=3600',
        ),
        props: <String>['PASSWORD', 'access_token'],
      );

      expect(result['request']['payload'], 'username=alice&remember=1');
      expect(result['response']['responseText'], 'expires=3600');
    });

    test('removes query params from the url and keeps the rest', () {
      expect(
        redact(
          entry(url: 'https://api.example.com/a?Token=1&page=2&token=3#frag'),
          props: <String>['token'],
        )['url'],
        'https://api.example.com/a?page=2#frag',
      );
      expect(
        redact(
          entry(url: 'https://api.example.com/a?api_key=1'),
          props: <String>['API_KEY'],
        )['url'],
        'https://api.example.com/a',
      );
      expect(
        redact(
          entry(url: 'https://api.example.com/a#x?token=1'),
          props: <String>['token'],
        )['url'],
        'https://api.example.com/a#x?token=1',
      );
    });
  });

  test('never modifies the input entry', () {
    final Map<String, dynamic> input = entry(
      url: 'https://api.example.com/a?token=1',
      requestHeaders: <String, dynamic>{'Authorization': 'Bearer abc'},
      payload: '{"password":"p1"}',
    );
    final String before = jsonEncode(input);

    redact(input, props: <String>['password', 'token']);

    expect(jsonEncode(input), before);
  });

  test('normalizeList trims, drops empty values and dedupes', () {
    expect(
      GleapNetworkLogRedaction.normalizeList(
        <dynamic>[' token ', 'TOKEN', '', null, 'password'],
      ),
      <String>['token', 'password'],
    );
  });

  group('GleapNetworkLogStore', () {
    GleapNetworkLogStore store() => GleapNetworkLogStore(
          push: (_) async {},
          canPush: () => false,
        );

    test('redacts entries when they are added', () {
      final GleapNetworkLogStore logs = store()
        ..setPropsToIgnore(<String>['password']);
      logs.add(entry(payload: '{"password":"p1","a":1}'));
      logs.add(entry(url: 'https://api.gleap.io/bugs'));

      expect(logs.entries, hasLength(1));
      expect(logs.entries.single['request']['payload'], '{"a":1}');
    });

    test('settings changed later apply to buffered entries', () {
      final GleapNetworkLogStore logs = store();
      logs.add(entry(
        url: 'https://api.example.com/a?token=1',
        payload: '{"password":"p1","a":1}',
      ));
      logs.add(entry(url: 'https://internal.example.com/metrics'));

      logs.setPropsToIgnore(<String>['password', 'token']);
      logs.setBlacklist(<String>['internal.example.com']);

      expect(logs.entries, hasLength(1));
      expect(logs.entries.single['url'], 'https://api.example.com/a');
      expect(logs.entries.single['request']['payload'], '{"a":1}');
    });

    test('replaceAll redacts the attached entries too', () async {
      final List<List<Map<String, dynamic>>> pushed =
          <List<Map<String, dynamic>>>[];
      final GleapNetworkLogStore logs = GleapNetworkLogStore(
        push: (List<Map<String, dynamic>> networkLogs) async {
          pushed.add(networkLogs);
        },
      );

      await logs.replaceAll(<Map<String, dynamic>>[
        entry(requestHeaders: <String, dynamic>{'cookie': 'sid=1'}),
        entry(url: 'https://gleap.ai/x'),
      ]);

      expect(pushed, hasLength(1));
      expect(pushed.single, hasLength(1));
      expect(pushed.single.single['request']['headers'], <String, dynamic>{
        'cookie': '[REDACTED]',
      });
    });
  });
}
