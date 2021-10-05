import 'dart:async';
import 'dart:html';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
// ignore: library_prefixes
import 'package:gleap_sdk/helpers/gleap_js_sdk_helper.dart' as GleapJsSdkHelper;

class GleapSdkWeb {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'gleap_sdk',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = GleapSdkWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'initialize':
        return initialize(token: call.arguments['token']);
      case 'identify':
        return identify(
          userId: call.arguments['userId'],
          userHash: call.arguments['userHash'],
          name: call.arguments['name'],
          email: call.arguments['email'],
        );
      case 'attachCustomData':
        return attachCustomData(customData: call.arguments['attachCustomData']);
      case 'setCustomData':
        return setCustomData(
          key: call.arguments['key'],
          value: call.arguments['value'],
        );
      case 'removeCustomData':
        return removeCustomData(key: call.arguments['key']);
      case 'registerCustomAction': // TODO
        return registerCustomAction();
      case 'logEvent':
        return logEvent(
            name: call.arguments('name'), data: call.arguments['data']);
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
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'gleap_sdk for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  Future<void> initialize({String? token}) async {
    if (token == null) {
      throw ('initialize - token null');
    }

    ScriptElement scriptElement = ScriptElement();
    scriptElement.src = "https://widget.gleap.io/widget/$token";
    document.body?.append(scriptElement);
  }

  Future<void> identify({
    required String userId,
    required String userHash,
    String? name,
    String? email,
  }) async {
    await GleapJsSdkHelper.identify(userId, userHash, name, email);
  }

  Future<void> attachCustomData(
      {required Map<String, dynamic> customData}) async {
    await GleapJsSdkHelper.attachCustomData(customData);
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

  Future<void> registerCustomAction() async {}

  Future<void> logEvent(
      {required String name, Map<String, dynamic>? data}) async {
    await GleapJsSdkHelper.logEvent(name);
    // TODO data
  }

  Future<void> sendSilentBugReport(
      {required String description, required String severity}) async {
    // TODO severity
  }

  Future<void> openWidget() async {
    await GleapJsSdkHelper.open();
  }

  Future<void> hideWidget() async {
    await GleapJsSdkHelper.hide();
  }

  Future<void> startFeedbackFlow() async {
    await GleapJsSdkHelper.startFeedbackFlow();
  }
}
