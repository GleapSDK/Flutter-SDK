@JS()
library gleap;

import 'package:js/js.dart';

@JS('window.Gleap.identify')
external Future<void> identify(
  String userId,
  String userHash,
  String? name,
  String? email,
);

@JS('window.Gleap.attachCustomData')
external Future<void> attachCustomData(Map<String, dynamic> customData);

@JS('window.Gleap.setCustomData')
external Future<void> setCustomData(String key, String value);

@JS('window.Gleap.removeCustomData')
external Future<void> removeCustomData(String key);

@JS('window.Gleap.clearCustomData')
external Future<void> clearCustomData();

@JS('window.Gleap.logEvent')
external Future<void> logEvent(String event);

@JS('window.Gleap.open')
external Future<void> open();

@JS('window.Gleap.hide')
external Future<void> hide();

@JS('window.Gleap.startFeedbackFlow')
external Future<void> startFeedbackFlow();
