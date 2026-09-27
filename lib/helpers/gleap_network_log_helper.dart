import 'dart:convert';
import 'dart:typed_data';

/// Shared building blocks for Gleap network log entries.
///
/// Used by the network log models, [Gleap.logNetworkRequest] and the Gleap
/// http / dio interceptor packages, so every entry has the same shape:
/// ISO-8601 UTC dates, string header values, text bodies capped at
/// [maxBodyLength] and the same markers for bodies that are not captured.
class GleapNetworkLogHelper {
  GleapNetworkLogHelper._();

  /// Maximum length of a captured request / response body.
  static const int maxBodyLength = 150000;

  static const String binaryBodyMarker = '[binary body omitted]';
  static const String streamingBodyMarker = '[streaming body omitted]';
  static const String bodyNotCapturedMarker = '[body not captured]';
  static const String bodyPendingMarker = '[body pending]';

  static const List<String> _streamingContentTypes = <String>[
    'text/event-stream',
    'application/x-ndjson',
    'application/stream+json',
    'multipart/x-mixed-replace',
    'grpc',
  ];

  static const List<String> _textContentTypes = <String>[
    'json',
    'xml',
    'text/',
    'javascript',
    'x-www-form-urlencoded',
    'graphql',
  ];

  /// Formats [date] as ISO-8601 UTC with millisecond precision
  /// (`2026-09-27T10:00:00.123Z`).
  static String isoDate(DateTime date) {
    return DateTime.fromMillisecondsSinceEpoch(
      date.millisecondsSinceEpoch,
      isUtc: true,
    ).toIso8601String();
  }

  /// True for content types that are streamed and must never be buffered
  /// (server-sent events, ndjson, grpc, ...).
  static bool isStreamingContentType(String? contentType) {
    if (contentType == null) {
      return false;
    }

    final String lower = contentType.toLowerCase();
    return _streamingContentTypes.any(lower.contains);
  }

  /// True for text-like content types whose bodies are captured.
  static bool isTextContentType(String? contentType) {
    if (contentType == null || isStreamingContentType(contentType)) {
      return false;
    }

    final String lower = contentType.toLowerCase();
    return _textContentTypes.any(lower.contains);
  }

  /// Returns the value of the header [name] (case-insensitive) or null.
  static String? headerValue(Map<dynamic, dynamic>? headers, String name) {
    if (headers == null) {
      return null;
    }

    final String lowerName = name.toLowerCase();
    for (final MapEntry<dynamic, dynamic> entry in headers.entries) {
      if (entry.key?.toString().toLowerCase() == lowerName) {
        return _headerValueToString(entry.value);
      }
    }

    return null;
  }

  /// Converts [headers] to `{name: "value"}`. List values (repeated
  /// headers) are joined with ", ", null values are dropped.
  static Map<String, String>? prepareHeaders(Map<dynamic, dynamic>? headers) {
    if (headers == null) {
      return null;
    }

    final Map<String, String> prepared = <String, String>{};
    headers.forEach((dynamic key, dynamic value) {
      if (key == null) {
        return;
      }

      final String? preparedValue = _headerValueToString(value);
      if (preparedValue != null) {
        prepared[key.toString()] = preparedValue;
      }
    });

    return prepared;
  }

  static String? _headerValueToString(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Iterable) {
      return value
          .where((dynamic element) => element != null)
          .map((dynamic element) => element.toString())
          .join(', ');
    }

    return value.toString();
  }

  /// Converts a request / response body to text.
  ///
  /// Strings are kept as they are, Maps / Lists (and objects with a
  /// `toJson()` method) are JSON-encoded, bytes and streams become markers.
  /// The result is not capped, see [capBody].
  static String stringifyBody(dynamic body) {
    try {
      if (body == null) {
        return '';
      }

      if (body is String) {
        return body;
      }

      if (body is TypedData || body is ByteBuffer) {
        return binaryBodyMarker;
      }

      if (body is Stream) {
        return streamingBodyMarker;
      }

      if (body is num || body is bool) {
        return body.toString();
      }

      if (body is Map || body is Iterable) {
        return _encodeJson(body);
      }

      dynamic json;
      try {
        json = body.toJson();
      } catch (_) {
        return body.toString();
      }

      return json is String ? json : _encodeJson(json);
    } catch (_) {
      return bodyNotCapturedMarker;
    }
  }

  static String _encodeJson(dynamic value) {
    try {
      return jsonEncode(
        value is Iterable && value is! List ? value.toList() : value,
        toEncodable: _toEncodable,
      );
    } catch (_) {
      return value.toString();
    }
  }

  static Object? _toEncodable(dynamic object) {
    if (object is Iterable) {
      return object.toList();
    }

    if (object is DateTime) {
      return object.toIso8601String();
    }

    try {
      return object.toJson();
    } catch (_) {}

    return object.toString();
  }

  /// Caps [body] at [maxBodyLength] characters. Longer bodies keep their
  /// head followed by `\n… [truncated, <total> bytes]`.
  ///
  /// Pass [totalBytes] only when [body] is already just the head of a larger
  /// body (e.g. a captured stream prefix): the complete size in bytes, or
  /// `-1` when it is unknown ("more than 150000").
  static String capBody(String body, {int? totalBytes}) {
    if (totalBytes == null && body.length <= maxBodyLength) {
      return body;
    }

    String head = body;
    if (head.length > maxBodyLength) {
      int end = maxBodyLength;
      // Do not split a surrogate pair.
      final int lastUnit = head.codeUnitAt(end - 1);
      if (lastUnit >= 0xD800 && lastUnit <= 0xDBFF) {
        end -= 1;
      }
      head = head.substring(0, end);
    }

    final int total = totalBytes ?? _utf8Length(body);
    final String size =
        total < 0 ? 'more than $maxBodyLength' : total.toString();

    return '$head\n… [truncated, $size bytes]';
  }

  /// Decodes a captured body as text.
  ///
  /// [bytes] holds the body or (at most [maxBodyLength] bytes of) its head;
  /// [totalBytes] is the complete size (`-1` when unknown, defaults to
  /// `bytes.length`). Declared text content types are decoded leniently;
  /// otherwise the body is only captured when it is valid UTF-8 text, else
  /// the binary marker is returned.
  static String decodeBody(
    List<int> bytes, {
    String? contentType,
    int? totalBytes,
  }) {
    try {
      if (bytes.isEmpty) {
        return '';
      }

      final int total = totalBytes ?? bytes.length;
      final bool truncated = total < 0 || total > bytes.length;
      final String lowerContentType = (contentType ?? '').trim().toLowerCase();

      String? text;
      if (lowerContentType.isEmpty) {
        text = _strictUtf8(bytes, truncated: truncated);
      } else if (isStreamingContentType(lowerContentType)) {
        return streamingBodyMarker;
      } else if (!isTextContentType(lowerContentType)) {
        return binaryBodyMarker;
      } else if (lowerContentType.contains('iso-8859-1') ||
          lowerContentType.contains('latin1')) {
        text = latin1.decode(bytes, allowInvalid: true);
      } else {
        text = utf8.decode(bytes, allowMalformed: true);
      }

      if (text == null) {
        return binaryBodyMarker;
      }

      return capBody(text, totalBytes: truncated ? total : null);
    } catch (_) {
      return bodyNotCapturedMarker;
    }
  }

  static String? _strictUtf8(List<int> bytes, {required bool truncated}) {
    // A cut body can end in the middle of a multi-byte character.
    final int maxTrim = truncated ? 3 : 0;
    for (int trim = 0; trim <= maxTrim && trim < bytes.length; trim++) {
      try {
        final String text = utf8.decode(
          trim == 0 ? bytes : bytes.sublist(0, bytes.length - trim),
        );
        if (text.contains('\u0000')) {
          return null;
        }
        return text;
      } on FormatException {
        continue;
      }
    }

    return null;
  }

  static int _utf8Length(String value) {
    int length = 0;
    for (int i = 0; i < value.length; i++) {
      final int unit = value.codeUnitAt(i);
      if (unit < 0x80) {
        length += 1;
      } else if (unit < 0x800) {
        length += 2;
      } else if (unit >= 0xD800 &&
          unit <= 0xDBFF &&
          i + 1 < value.length &&
          value.codeUnitAt(i + 1) >= 0xDC00 &&
          value.codeUnitAt(i + 1) <= 0xDFFF) {
        length += 4;
        i++;
      } else {
        length += 3;
      }
    }

    return length;
  }
}
