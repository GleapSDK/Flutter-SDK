@JS()
library gleap;

import 'package:js/js.dart';

@JS('window.Gleap.initialize')
external Future<void> initialize(
  String token,
);

@JS('window.Gleap.identify')
external Future<void> identify(
  String userId,
  String? userData,
  String? userHash,
);

@JS('window.Gleap.clearIdentity')
external Future<void> clearIdentity();

@JS('window.Gleap.attachCustomData')
external Future<void> attachCustomData(String customData);

@JS('window.Gleap.preFillForm')
external Future<void> preFillForm(String formData);

@JS('window.Gleap.setCustomData')
external Future<void> setCustomData(String key, String value);

@JS('window.Gleap.removeCustomData')
external Future<void> removeCustomData(String key);

@JS('window.Gleap.clearCustomData')
external Future<void> clearCustomData();

@JS('Gleap.registerCustomAction')
external void registerCustomAction(
    void Function(dynamic action) callbackHandler);

@JS('window.Gleap.on')
external void registerEvents(
    String name, void Function(dynamic data) callbackHandler);

@JS('window.Gleap.logEvent')
external Future<void> logEvent(String event, String? data);

@JS('window.Gleap.sendSilentCrashReport')
external Future<void> sendSilentCrashReport(
    String description, String severity, Map<String, dynamic> excludeData);

@JS('window.Gleap.open')
external Future<void> open();

@JS('window.Gleap.hide')
external Future<void> hide();

@JS('window.Gleap.startFeedbackFlow')
external Future<void> startFeedbackFlow(String flow, bool showBackButton);

@JS('window.Gleap.setLanguage')
external Future<void> setLanguage(String language);
