import 'dart:async';

import 'package:gleap_sdk/helpers/gleap_network_log_redaction.dart';

/// Pushes the complete list of network log entries to the platform side.
typedef GleapNetworkLogPush = Future<void> Function(
  List<Map<String, dynamic>> networkLogs,
);

/// Shared buffer behind [Gleap.logNetworkRequest] and
/// [Gleap.attachNetworkLogs].
///
/// Keeps the newest [maxEntries] entries (redacted and blacklisted with the
/// local settings when they are added, and again whenever the settings
/// change) and hands the complete list to [push] at most once per
/// [pushDelay] (trailing), never on every request. Every interceptor adds to
/// this one buffer, so several interceptors no longer overwrite each other.
class GleapNetworkLogStore {
  GleapNetworkLogStore({
    required GleapNetworkLogPush push,
    bool Function()? canPush,
    this.maxEntries = 30,
    this.pushDelay = const Duration(milliseconds: 500),
  })  : _push = push,
        _canPush = canPush ?? (() => true);

  final GleapNetworkLogPush _push;
  final bool Function() _canPush;
  final int maxEntries;
  final Duration pushDelay;

  final List<Map<String, dynamic>> _entries = <Map<String, dynamic>>[];
  List<String> _propsToIgnore = const <String>[];
  List<String> _blacklist = const <String>[];
  Timer? _pushTimer;

  /// The buffered (already redacted) entries, oldest first.
  List<Map<String, dynamic>> get entries =>
      List<Map<String, dynamic>>.unmodifiable(_entries);

  List<String> get propsToIgnore => _propsToIgnore;

  List<String> get blacklist => _blacklist;

  /// Adds an entry and schedules a push. Never throws.
  void add(Map<String, dynamic> entry) {
    try {
      final Map<String, dynamic>? redacted = _redact(entry);
      if (redacted == null) {
        return;
      }

      _entries.add(redacted);
      _trim();
      _schedulePush();
    } catch (_) {}
  }

  /// Replaces all entries and pushes the new list right away.
  Future<void> replaceAll(Iterable<Map<String, dynamic>> entries) async {
    try {
      _entries.clear();
      for (final Map<String, dynamic> entry in entries) {
        final Map<String, dynamic>? redacted = _redact(entry);
        if (redacted != null) {
          _entries.add(redacted);
        }
      }
      _trim();
    } catch (_) {}

    await flush();
  }

  /// Replaces the local props to ignore (headers, JSON keys, form fields and
  /// query params) and re-applies the redaction to the buffered entries.
  void setPropsToIgnore(Iterable<dynamic>? propsToIgnore) {
    _propsToIgnore = GleapNetworkLogRedaction.normalizeList(propsToIgnore);
    _reapply();
  }

  /// Replaces the local url blacklist and re-applies it to the buffered
  /// entries.
  void setBlacklist(Iterable<dynamic>? blacklist) {
    _blacklist = GleapNetworkLogRedaction.normalizeList(blacklist);
    _reapply();
  }

  /// Pushes the current list now (cancels a scheduled push). Never throws.
  Future<void> flush() async {
    _pushTimer?.cancel();
    _pushTimer = null;

    if (!_canPush()) {
      return;
    }

    try {
      await _push(List<Map<String, dynamic>>.of(_entries));
    } catch (_) {}
  }

  /// Drops all entries and cancels a scheduled push (local settings stay).
  void clear() {
    _pushTimer?.cancel();
    _pushTimer = null;
    _entries.clear();
  }

  Map<String, dynamic>? _redact(Map<String, dynamic> entry) {
    return GleapNetworkLogRedaction.redactEntry(
      entry,
      propsToIgnore: _propsToIgnore,
      blacklist: _blacklist,
    );
  }

  void _reapply() {
    if (_entries.isEmpty) {
      return;
    }

    try {
      final List<Map<String, dynamic>> redacted =
          GleapNetworkLogRedaction.redactEntries(
        _entries,
        propsToIgnore: _propsToIgnore,
        blacklist: _blacklist,
      );
      _entries
        ..clear()
        ..addAll(redacted);
    } catch (_) {}

    _schedulePush();
  }

  void _trim() {
    if (_entries.length > maxEntries) {
      _entries.removeRange(0, _entries.length - maxEntries);
    }
  }

  void _schedulePush() {
    // Trailing throttle: the first change starts the timer, later changes
    // ride along, so a steady stream of requests still gets pushed.
    if (_pushTimer != null || !_canPush()) {
      return;
    }

    _pushTimer = Timer(pushDelay, () {
      _pushTimer = null;
      flush();
    });
  }
}
