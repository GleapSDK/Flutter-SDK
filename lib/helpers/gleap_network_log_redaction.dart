import 'dart:convert';

/// Redaction and blacklisting for Gleap network log entries.
///
/// Works on entries in the JSON shape Gleap sends (`url`, `request.headers`,
/// `request.payload`, `response.headers`, `response.responseText`). Inputs
/// are never modified; a redacted copy is returned.
///
/// * Entries whose url contains a blacklist entry (or `gleap.io` /
///   `gleap.ai`) are dropped.
/// * Headers named like a prop are removed (case-insensitive).
/// * `authorization`, `proxy-authorization`, `cookie` and `set-cookie`
///   headers are always masked with `[REDACTED]`.
/// * JSON bodies: keys named like a prop are removed at any depth, a prop
///   containing `.` is also applied as a path from the root. JSON bodies
///   that do not parse (cut at the size limit) get the values of matching
///   keys masked with `[REDACTED]` instead.
/// * `application/x-www-form-urlencoded` bodies and url query parameters:
///   params named like a prop are removed.
///
/// Prop names match case-insensitively everywhere. Bodies without a match
/// are returned untouched.
class GleapNetworkLogRedaction {
  GleapNetworkLogRedaction._();

  /// Always blacklisted, in addition to the configured blacklist.
  static const List<String> defaultBlacklist = <String>['gleap.io', 'gleap.ai'];

  /// Headers whose values are always replaced with [redactedValue].
  static const List<String> maskedHeaders = <String>[
    'authorization',
    'proxy-authorization',
    'cookie',
    'set-cookie',
  ];

  static const String redactedValue = '[REDACTED]';

  /// Trims, drops empty values and dedupes (keeps the first spelling).
  static List<String> normalizeList(Iterable<dynamic>? values) {
    if (values == null) {
      return const <String>[];
    }

    final List<String> normalized = <String>[];
    final Set<String> seen = <String>{};
    for (final dynamic value in values) {
      if (value == null) {
        continue;
      }

      final String trimmed = value.toString().trim();
      if (trimmed.isEmpty || !seen.add(trimmed.toLowerCase())) {
        continue;
      }

      normalized.add(trimmed);
    }

    return List<String>.unmodifiable(normalized);
  }

  /// True when [url] contains [defaultBlacklist] or [blacklist] entries.
  static bool isBlacklisted(String? url, Iterable<String> blacklist) {
    if (url == null || url.isEmpty) {
      return false;
    }

    final String lowerUrl = url.toLowerCase();
    for (final String entry in <String>[...defaultBlacklist, ...blacklist]) {
      if (entry.isNotEmpty && lowerUrl.contains(entry.toLowerCase())) {
        return true;
      }
    }

    return false;
  }

  /// Applies [redactEntry] to every entry and drops blacklisted ones.
  static List<Map<String, dynamic>> redactEntries(
    Iterable<Map<String, dynamic>> entries, {
    Iterable<String> propsToIgnore = const <String>[],
    Iterable<String> blacklist = const <String>[],
  }) {
    final List<String> props = normalizeList(propsToIgnore);
    final List<String> list = normalizeList(blacklist);
    final List<Map<String, dynamic>> result = <Map<String, dynamic>>[];
    for (final Map<String, dynamic> entry in entries) {
      final Map<String, dynamic>? redacted =
          redactEntry(entry, propsToIgnore: props, blacklist: list);
      if (redacted != null) {
        result.add(redacted);
      }
    }

    return result;
  }

  /// Returns a redacted copy of [entry], or null when it is blacklisted.
  static Map<String, dynamic>? redactEntry(
    Map<String, dynamic> entry, {
    Iterable<String> propsToIgnore = const <String>[],
    Iterable<String> blacklist = const <String>[],
  }) {
    final dynamic url = entry['url'];
    if (isBlacklisted(url is String ? url : null, blacklist)) {
      return null;
    }

    final Set<String> props = normalizeList(propsToIgnore)
        .map((String prop) => prop.toLowerCase())
        .toSet();
    final Map<String, dynamic> redacted = Map<String, dynamic>.of(entry);

    if (url is String && props.isNotEmpty) {
      redacted['url'] = redactUrl(url, props);
    }

    final dynamic request = entry['request'];
    if (request is Map) {
      redacted['request'] = _redactMessage(
        request,
        bodyKey: 'payload',
        props: props,
      );
    }

    final dynamic response = entry['response'];
    if (response is Map) {
      redacted['response'] = _redactMessage(
        response,
        bodyKey: 'responseText',
        props: props,
      );
    }

    return redacted;
  }

  static Map<String, dynamic> _redactMessage(
    Map<dynamic, dynamic> message, {
    required String bodyKey,
    required Set<String> props,
  }) {
    final Map<String, dynamic> redacted = <String, dynamic>{};
    message.forEach((dynamic key, dynamic value) {
      redacted[key.toString()] = value;
    });

    final dynamic headers = message['headers'];
    if (headers is Map) {
      redacted['headers'] = redactHeaders(headers, props);
    }

    final dynamic body = message[bodyKey];
    if (body is String && props.isNotEmpty) {
      final String? contentType =
          headers is Map ? _headerValue(headers, 'content-type') : null;
      redacted[bodyKey] = redactBody(body, props, contentType: contentType);
    }

    return redacted;
  }

  /// Removes headers named like a prop and masks credential headers.
  /// [props] must be lower case.
  static Map<String, dynamic> redactHeaders(
    Map<dynamic, dynamic> headers,
    Set<String> props,
  ) {
    final Map<String, dynamic> redacted = <String, dynamic>{};
    headers.forEach((dynamic key, dynamic value) {
      final String name = key.toString();
      final String lowerName = name.toLowerCase();
      if (props.contains(lowerName)) {
        return;
      }

      redacted[name] = maskedHeaders.contains(lowerName) ? redactedValue : value;
    });

    return redacted;
  }

  /// Redacts a JSON or form-urlencoded body. Returns [body] untouched when
  /// nothing matched. [props] must be lower case.
  static String redactBody(
    String body,
    Set<String> props, {
    String? contentType,
  }) {
    if (props.isEmpty || body.isEmpty) {
      return body;
    }

    final String trimmed = body.trimLeft();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      dynamic decoded;
      try {
        decoded = jsonDecode(body);
      } catch (_) {
        // Cut at the size limit (or otherwise broken): mask what is visible.
        return _maskUnparsedJson(body, props);
      }

      return _redactJson(decoded, props) ?? body;
    }

    if (contentType != null &&
        contentType.toLowerCase().contains('x-www-form-urlencoded')) {
      return _redactQuery(body, props) ?? body;
    }

    return body;
  }

  /// Removes query parameters named like a prop. [props] must be lower case.
  static String redactUrl(String url, Set<String> props) {
    if (props.isEmpty) {
      return url;
    }

    final int queryStart = url.indexOf('?');
    if (queryStart < 0) {
      return url;
    }

    final int fragmentStart = url.indexOf('#');
    if (fragmentStart >= 0 && fragmentStart < queryStart) {
      return url;
    }

    final int queryEnd = fragmentStart >= 0 ? fragmentStart : url.length;
    final String? query =
        _redactQuery(url.substring(queryStart + 1, queryEnd), props);
    if (query == null) {
      return url;
    }

    return url.substring(0, queryStart) +
        (query.isEmpty ? '' : '?$query') +
        url.substring(queryEnd);
  }

  /// Removes matching keys from a decoded JSON body. Returns null when
  /// nothing was removed.
  static String? _redactJson(dynamic decoded, Set<String> props) {
    if (decoded is! Map && decoded is! List) {
      return null;
    }

    bool changed = _removeKeys(decoded, props);
    for (final String prop in props) {
      if (!prop.contains('.')) {
        continue;
      }

      final List<String> path = prop.split('.');
      if (path.any((String segment) => segment.isEmpty)) {
        continue;
      }

      if (_removePath(decoded, path, 0)) {
        changed = true;
      }
    }

    if (!changed) {
      return null;
    }

    try {
      return jsonEncode(decoded);
    } catch (_) {
      return null;
    }
  }

  static final RegExp _truncationNote =
      RegExp(r'\n… \[truncated, (?:\d+|more than \d+) bytes\]$');

  /// Masks the values of matching keys in a JSON body that does not parse
  /// (e.g. cut at the size limit): every prop, plus the last segment of a
  /// dotted prop, case-insensitive. String, number, boolean and null values
  /// become `"[REDACTED]"` (a string cut at the end too); objects and arrays
  /// are left alone, their keys are matched on their own. A trailing
  /// truncation note is kept. Returns [body] itself when nothing matched.
  static String _maskUnparsedJson(String body, Set<String> props) {
    final Set<String> keys = <String>{};
    for (final String prop in props) {
      keys.add(prop);
      final int lastDot = prop.lastIndexOf('.');
      if (lastDot >= 0 && lastDot < prop.length - 1) {
        keys.add(prop.substring(lastDot + 1));
      }
    }

    // Keep the truncation note out of reach of a string value cut at the end.
    final RegExpMatch? note = _truncationNote.firstMatch(body);
    String head = note == null ? body : body.substring(0, note.start);
    final String tail = note == null ? '' : body.substring(note.start);

    bool changed = false;
    for (final String key in keys) {
      final RegExp pattern = RegExp(
        '"(${RegExp.escape(key)})"'
        r'(\s*:\s*)("(?:[^"\\]|\\.)*"?|-?\d[0-9.eE+-]*|true|false|null)',
        caseSensitive: false,
      );
      head = head.replaceAllMapped(pattern, (Match match) {
        changed = true;
        return '"${match[1]}"${match[2]}"$redactedValue"';
      });
    }

    return changed ? head + tail : body;
  }

  static bool _removeKeys(dynamic node, Set<String> props) {
    bool changed = false;
    if (node is Map) {
      final List<dynamic> keys = node.keys
          .where((dynamic key) => props.contains(key.toString().toLowerCase()))
          .toList();
      for (final dynamic key in keys) {
        node.remove(key);
        changed = true;
      }

      for (final dynamic value in node.values) {
        if (_removeKeys(value, props)) {
          changed = true;
        }
      }
    } else if (node is List) {
      for (final dynamic value in node) {
        if (_removeKeys(value, props)) {
          changed = true;
        }
      }
    }

    return changed;
  }

  static bool _removePath(dynamic node, List<String> path, int index) {
    if (node is List) {
      bool changed = false;
      for (final dynamic value in node) {
        if (_removePath(value, path, index)) {
          changed = true;
        }
      }
      return changed;
    }

    if (node is! Map) {
      return false;
    }

    final String segment = path[index];
    final List<dynamic> keys = node.keys
        .where((dynamic key) => key.toString().toLowerCase() == segment)
        .toList();
    if (keys.isEmpty) {
      return false;
    }

    if (index == path.length - 1) {
      for (final dynamic key in keys) {
        node.remove(key);
      }
      return true;
    }

    bool changed = false;
    for (final dynamic key in keys) {
      if (_removePath(node[key], path, index + 1)) {
        changed = true;
      }
    }

    return changed;
  }

  /// Removes `name=value` pairs whose (decoded) name matches a prop.
  /// Returns null when nothing was removed.
  static String? _redactQuery(String query, Set<String> props) {
    bool changed = false;
    final List<String> kept = <String>[];
    for (final String pair in query.split('&')) {
      final int separator = pair.indexOf('=');
      final String rawName = separator >= 0 ? pair.substring(0, separator) : pair;
      String name = rawName;
      try {
        name = Uri.decodeQueryComponent(rawName);
      } catch (_) {}

      if (name.isNotEmpty && props.contains(name.toLowerCase())) {
        changed = true;
        continue;
      }

      kept.add(pair);
    }

    return changed ? kept.join('&') : null;
  }

  static String? _headerValue(Map<dynamic, dynamic> headers, String name) {
    for (final MapEntry<dynamic, dynamic> entry in headers.entries) {
      if (entry.key.toString().toLowerCase() == name) {
        final dynamic value = entry.value;
        return value is Iterable ? value.join(', ') : value?.toString();
      }
    }

    return null;
  }
}
