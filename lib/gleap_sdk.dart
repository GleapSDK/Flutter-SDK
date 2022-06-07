// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:gleap_sdk/models/callback_item_model/callback_item_model.dart';
import 'package:gleap_sdk/models/gleap_network_log_models/gleap_network_log_model/gleap_network_log_model.dart';
import 'package:gleap_sdk/models/gleap_user_property_model/gleap_user_property_model.dart';

enum Severity { LOW, MEDIUM, HIGH }

String _getSeverityValue(Severity bugPriority) {
  switch (bugPriority) {
    case Severity.LOW:
      return "LOW";
    case Severity.MEDIUM:
      return "MEDIUM";
    case Severity.HIGH:
      return "HIGH";
    default:
      return "MEDIUM";
  }
}

enum ActivationMethod { SHAKE, SCREENSHOT }

String _getActivationMethodValue(ActivationMethod activationMethod) {
  switch (activationMethod) {
    case ActivationMethod.SHAKE:
      return "SHAKE";
    case ActivationMethod.SCREENSHOT:
      return "SCREENSHOT";
    default:
      return "SHAKE";
  }
}

class Gleap {
  static const MethodChannel _channel = MethodChannel('gleap_sdk');
  static final List<CallbackItem> _callbackItems = <CallbackItem>[];

  static _initCallbackHandler() async {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'feedbackWillBeSentCallback') {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        WidgetsBinding.instance.focusManager.rootScope.requestFocus(
          FocusNode(),
        );
      }

      List<CallbackItem> callbackItem = _callbackItems
          .where(
            (CallbackItem element) =>
                element.callbackName == call.method ||
                (call.method == "customActionTriggered" &&
                    call.arguments["name"] == element.callbackName),
          )
          .toList();

      if (callbackItem.isNotEmpty) {
        dynamic callbackArgs = call.arguments;
        if (!kIsWeb && io.Platform.isAndroid) {
          try {
            Map<String, dynamic> callbackArgsConverted = json.decode(
              callbackArgs.toString(),
            );

            callbackArgs = callbackArgsConverted;
          } catch (_) {}
        }

        CallbackItem currentCallback = callbackItem.first;
        currentCallback.callbackHandler(callbackArgs);
      }
    });
  }

  /// ### initialize
  ///
  /// Auto-configures the Gleap SDK from the remote config.
  ///
  /// **Params**
  ///
  /// [token] The SDK key, which can be found on dashboard.bugbattle.io
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS, Web
  static Future<void> initialize({
    required String token,
  }) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint('initialize is not available for current operating system');
      return;
    }

    await _channel.invokeMethod(
      'initialize',
      {'token': token},
    );

    _initCallbackHandler();
  }

  /// ### startFeedbackFlow
  ///
  /// Manually start the bug reporting workflow. This is used, when you use the activation method "NONE".
  ///
  /// [GleapNotInitialisedException] thrown when Gleap is not initialised
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS, Web
  static Future<void> startFeedbackFlow({
    required String feedbackAction,
    bool showBackButton = true,
  }) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
          'startFeedbackFlow is not available for current operating system');
      return;
    }

    await _channel.invokeMethod(
      'startFeedbackFlow',
      {'action': feedbackAction, 'showBackButton': showBackButton},
    );
  }

  /// ### sendSilentCrashReport
  ///
  /// Send a silent bugreport in the background. Useful for automated ui tests.
  ///
  /// **Params**
  ///
  /// [description] Description of the bug
  ///
  /// [severity] Severity of the bug "LOW", "MIDDLE", "HIGH"
  ///
  /// [excludeData] Exclude data from the crash report
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS, Web
  static Future<void> sendSilentCrashReport({
    required String description,
    required Severity severity,
    Map<String, dynamic> excludeData = const {},
  }) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
          'sendSilentCrashReport is not available for current operating system');
      return;
    }

    String severityVal = _getSeverityValue(severity);

    await _channel.invokeMethod(
      'sendSilentCrashReport',
      {
        'description': description,
        'severity': severityVal,
        'excludeData': excludeData,
      },
    );
  }

  /// ### identify
  ///
  /// Updates a session's user data.
  ///
  /// **Params**
  ///
  /// [gleapUserSession] The updated user data.
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS, Web
  static Future<void> identify({
    required String userId,
    GleapUserProperty? userProperties,
    String? userHash,
  }) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'identify is not available for current operating system',
      );
      return;
    }

    if (userProperties != null && userHash != null) {
      await _channel.invokeMethod(
        'identify',
        {
          'userId': userId,
          'userProperties': userProperties.toJson(),
          'userHash': userHash,
        },
      );
    } else if (userProperties != null) {
      await _channel.invokeMethod(
        'identify',
        {
          'userId': userId,
          'userProperties': userProperties.toJson(),
        },
      );
    } else {
      await _channel.invokeMethod('identify', {'userId': userId});
    }
  }

  /// ### clearIdentity
  ///
  /// Clears a user session.
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS, Web
  static Future<void> clearIdentity() async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint('clearIdentity is not available for current operating system');
      return;
    }

    await _channel.invokeMethod('clearIdentity');
  }

  /// ### setLanguage
  ///
  /// Set the language for the Gleap Report Flow. Otherwise the default language is used.
  /// Supported Languages "en", "es", "fr", "it", "de", "nl", "cz"
  ///
  /// **Params**
  ///
  /// [language] Country Code eg. "cz," "en", "de", "es", "nl"
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS, Web
  static Future<void> setLanguage({required String language}) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint('setLanguage is not available for current operating system');
      return;
    }

    await _channel.invokeMethod('setLanguage', {'language': language});
  }

  /// ### setActivationMethods
  ///
  /// Overwrite the activation methods on the fly.
  ///
  /// **Params**
  ///
  /// [activationMethods] An array of activation methods.
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS
  static Future<void> setActivationMethods({
    required List<ActivationMethod> activationMethods,
  }) async {
    if (kIsWeb || (!io.Platform.isAndroid && !io.Platform.isIOS)) {
      debugPrint('setActivationMethods is not available for the web');
      return;
    }

    final List<String> activationMethodsVals = activationMethods
        .map((ActivationMethod activationMethod) =>
            _getActivationMethodValue(activationMethod))
        .toList();

    await _channel.invokeMethod(
      'setActivationMethods',
      {'activationMethods': activationMethodsVals},
    );
  }

  /// ### attachCustomData
  ///
  /// Attaches custom data, which can be viewed in the Gleap dashboard. New data will be merged with existing custom data.
  ///
  /// **Params**
  ///
  /// [customData] The data to attach to a bug report.
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS, Web
  static Future<void> attachCustomData({
    required Map<String, dynamic> customData,
  }) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
          'attachCustomData is not available for current operating system');
      return;
    }

    await _channel.invokeMethod(
      'attachCustomData',
      {'customData': customData},
    );
  }

  /// ### preFillForm
  ///
  /// Prefills a form with the given data.
  ///
  /// **Params**
  ///
  /// [formData] The data to prefill the form with.
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS, Web
  static Future<void> preFillForm({
    required Map<String, dynamic> formData,
  }) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint('preFillForm is not available for current operating system');
      return;
    }

    await _channel.invokeMethod(
      'preFillForm',
      {'formData': formData},
    );
  }

  /// ### setCustomData
  ///
  /// Attach one key value pair to existing custom data.
  ///
  /// **Params**
  ///
  /// [key] The value you want to add
  ///
  /// [value] The key of the attribute
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS, Web
  static Future<void> setCustomData({
    required String key,
    required String value,
  }) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint('setCustomData is not available for current operating system');
      return;
    }

    await _channel.invokeMethod(
      'setCustomData',
      {
        'key': key,
        'value': value,
      },
    );
  }

  /// ### removeCustomDataForKey
  ///
  /// Removes one key from existing custom data.
  ///
  /// **Params**
  ///
  /// [key] The key of the attribute
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS, Web
  static Future<void> removeCustomDataForKey({required String key}) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
          'removeCustomDataForKey is not available for current operating system');
      return;
    }

    await _channel.invokeMethod(
      'removeCustomDataForKey',
      {
        'key': key,
      },
    );
  }

  /// ### clearCustomData
  ///
  /// Clears all custom data.
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS, Web
  static Future<void> clearCustomData() async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'clearCustomData is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod('clearCustomData');
  }

  /// ### registerListener
  ///
  /// Register a custom action
  ///
  /// **Params**
  ///
  /// [actionName] The action which is listened to
  ///
  /// [callbackHandler] Is called when [actionName] is triggered
  ///
  /// ** Available Platorms**
  ///
  /// Android, iOS, Web
  static void registerListener({
    required String actionName,
    required Function(dynamic data) callbackHandler,
  }) {
    if (_callbackItems
        .where((CallbackItem element) => element.callbackName == actionName)
        .isNotEmpty) {
      debugPrint(
        '$actionName is already registered.',
      );
      return;
    }

    _callbackItems.add(
      CallbackItem(
        callbackName: actionName,
        callbackHandler: callbackHandler,
      ),
    );
  }

  /// ### logNetwork
  ///
  /// Log network traffic by logging it manually.
  ///
  /// **Params**
  ///
  /// [networkLogs] List of GleapNetworkLog
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS
  static Future<void> attachNetworkLogs({
    required List<GleapNetworkLog> networkLogs,
  }) async {
    if (kIsWeb || (!io.Platform.isAndroid && !io.Platform.isIOS)) {
      debugPrint(
        'attachNetworkLogs is not available for current operating system',
      );
      return;
    }

    List<Map<String, dynamic>> jsonNetworkLogs = <Map<String, dynamic>>[];
    for (int i = 0; i < networkLogs.length; i++) {
      try {
        jsonNetworkLogs.add(networkLogs[i].toJson());
      } catch (_) {}
    }

    await _channel.invokeMethod(
      'attachNetworkLogs',
      {
        'networkLogs': jsonNetworkLogs,
      },
    );
  }

  /// ### logEvent
  ///
  /// Logs a custom event
  ///
  /// **Params**
  ///
  /// [name] Name of the event
  ///
  /// [data] Data passed with the event.
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS, Web
  static Future<void> logEvent({
    required String name,
    Map<String, dynamic>? data,
  }) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint('logEvent is not available for current operating system');
      return;
    }

    data ??= <String, dynamic>{};

    await _channel.invokeMethod('logEvent', {'name': name, 'data': data});
  }

  /// ### addAttachment
  ///
  /// Attaches a file to the bug report
  ///
  /// **Params**
  ///
  /// [name] The file name
  ///
  /// [file] The file to attach to the bug report
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS
  static Future<void> addAttachment({
    required String base64file,
    required String fileName,
  }) async {
    if (kIsWeb || (!io.Platform.isAndroid && !io.Platform.isIOS)) {
      debugPrint('addAttachment is not available for current operating system');
      return;
    }

    await _channel.invokeMethod(
      'addAttachment',
      {
        'base64file': base64file,
        'fileName': fileName,
      },
    );
  }

  /// ### removeAllAttachments
  ///
  /// Removes all attachments
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS
  static Future<void> removeAllAttachments() async {
    if (kIsWeb || (!io.Platform.isAndroid && !io.Platform.isIOS)) {
      debugPrint(
        'removeAllAttachments is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod('removeAllAttachments');
  }

  /// ### open
  ///
  /// Opens the feedback widget
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<void> open() async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'openWidget is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod('openWidget');
  }

  /// ### close
  ///
  /// Closes the feedback widget
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<void> close() async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'closeWidget is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod('closeWidget');
  }

  /// ### enableDebugConsoleLog
  ///
  /// Enables console logs in debug mode
  ///
  /// **Available Platforms**
  ///
  /// iOS
  static Future<void> enableDebugConsoleLog() async {
    if (kIsWeb || !io.Platform.isIOS) {
      debugPrint(
        'enableDebugConsoleLog is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod('enableDebugConsoleLog');
  }

  /// ### setApiUrl
  ///
  /// Set a custom api url
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<void> setApiUrl({required String url}) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'setApiUrl is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod(
      'setApiUrl',
      {
        'url': url,
      },
    );
  }

  /// ### setFrameUrl
  ///
  /// Set a custom widget url
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<void> setFrameUrl({required String url}) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'setFrameUrl is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod(
      'setFrameUrl',
      {
        'url': url,
      },
    );
  }

  /// ### isOpened
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<bool> isOpened() async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'isOpened is not available for current operating system',
      );
      return false;
    }

    return await _channel.invokeMethod('isOpened');
  }
}
