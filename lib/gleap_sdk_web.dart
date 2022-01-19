import 'dart:async';
import 'dart:convert';
import 'dart:js';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
// ignore: library_prefixes
import 'package:gleap_sdk/helpers/gleap_js_sdk_helper.dart' as GleapJsSdkHelper;
import 'package:js/js.dart';

class GleapSdkWeb {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'gleap_sdk',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = GleapSdkWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);

    registerEvents(channel);
  }

  static void registerEvents(MethodChannel channel) {
    void Function(dynamic data) open = allowInterop((dynamic data) {
      channel.invokeMethod('widgetOpenedCalledback');
    });
    GleapJsSdkHelper.registerEvents('open', open);

    void Function(dynamic data) close = allowInterop((dynamic data) {
      channel.invokeMethod('widgetClosedCalledback');
    });
    GleapJsSdkHelper.registerEvents('close', close);

    void Function(dynamic data) feedbackSent = allowInterop((dynamic data) {
      channel.invokeMethod('feedbackSentCallback');
    });
    GleapJsSdkHelper.registerEvents('feedback-sent', feedbackSent);

    void Function(dynamic data) flowStartet = allowInterop((dynamic data) {
      channel.invokeMethod('feedbackWillBeSentCallback');
    });
    GleapJsSdkHelper.registerEvents('flow-started', flowStartet);

    void Function(dynamic data) errorWhileSending =
        allowInterop((dynamic data) {
      channel.invokeMethod('feedbackSendingFailedCallback');
    });
    GleapJsSdkHelper.registerEvents('error-while-sending', errorWhileSending);

    void Function(dynamic data) customActionCalled =
        allowInterop((dynamic data) {
      channel.invokeMethod(
        'customActionCallback',
        <String, dynamic>{'name': data.name},
      );
    });
    GleapJsSdkHelper.registerCustomAction(customActionCalled);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'initialize':
        return initialize(token: call.arguments['token']);
      case 'identify':
        return identify(
          userId: call.arguments['userId'],
          userProperties: call.arguments['userProperties'],
        );
      case 'clearIdentity':
        return clearIdentity();
      case 'attachCustomData':
        return attachCustomData(
          customData: call.arguments['customData'],
        );
      case 'setCustomData':
        return setCustomData(
          key: call.arguments['key'],
          value: call.arguments['value'],
        );
      case 'removeCustomDataForKey':
        return removeCustomData(key: call.arguments['key']);
      case 'clearCustomData':
        return clearCustomData();
      case 'logEvent':
        return logEvent(
          name: call.arguments['name'],
          data: call.arguments['data'],
        );
      case 'sendSilentBugReport':
        return sendSilentBugReport(
          description: call.arguments['description'],
          severity: call.arguments['severity'],
        );
      case 'openWidget':
        return openWidget();
      case 'hideWidget':
        return hideWidget();
      case 'startFeedbackFlow':
        return startFeedbackFlow();
      case 'setLanguage':
        return setLanguage(language: call.arguments['language']);
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'gleap_sdk for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  Future<void> initialize({required String token}) async {
    await GleapJsSdkHelper.initialize(token);
  }

  Future<void> identify({
    required String userId,
    dynamic userProperties,
  }) async {
    String? stringifiedHashMap = jsonEncode(userProperties);

    await GleapJsSdkHelper.identify(userId, stringifiedHashMap);
  }

  Future<void> clearIdentity() async {
    await GleapJsSdkHelper.clearIdentity();
  }

  Future<void> attachCustomData({required dynamic customData}) async {
    String? stringifiedHashMap = jsonEncode(customData);

    await GleapJsSdkHelper.attachCustomData(stringifiedHashMap);
  }

  Future<void> setCustomData({
    required String key,
    required String value,
  }) async {
    await GleapJsSdkHelper.setCustomData(key, value);
  }

  Future<void> removeCustomData({required String key}) async {
    await GleapJsSdkHelper.removeCustomData(key);
  }

  Future<void> clearCustomData() async {
    await GleapJsSdkHelper.clearCustomData();
  }

  Future<void> logEvent({
    required String name,
    dynamic data,
  }) async {
    String? stringifiedHashMap = jsonEncode(data);

    await GleapJsSdkHelper.logEvent(name, stringifiedHashMap);
  }

  Future<void> sendSilentBugReport({
    required String description,
    required String severity,
  }) async {
    await GleapJsSdkHelper.sendSilentBugReport(description, severity);
  }

  Future<void> openWidget() async {
    await GleapJsSdkHelper.open();
  }

  Future<void> hideWidget() async {
    await GleapJsSdkHelper.hide();
  }

  Future<void> startFeedbackFlow() async {
    await GleapJsSdkHelper.open();
  }

  Future<void> setLanguage({required String language}) async {
    await GleapJsSdkHelper.setLanguage(language);
  }
}
