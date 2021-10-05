// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:io' as io;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

enum LanguageCode { EN, DE, FR, IT, ES }

String _getLanguageCodeValue(LanguageCode languageCode) {
  switch (languageCode) {
    case LanguageCode.EN:
      return 'en';
    case LanguageCode.DE:
      return 'de';
    case LanguageCode.FR:
      return 'fr';
    case LanguageCode.IT:
      return 'it';
    case LanguageCode.ES:
      return 'es';
    default:
      return 'en';
  }
}

enum RequestType { GET, POST, PUT, DELETE }

String _getRequestTypeValue(RequestType requestType) {
  switch (requestType) {
    case RequestType.GET:
      return 'GET';
    case RequestType.POST:
      return 'POST';
    case RequestType.PUT:
      return 'PUT';
    case RequestType.DELETE:
      return 'DELETE';
    default:
      return 'GET';
  }
}

class GleapUserSession {
  String userId;
  String userHash;
  String? name;
  String? email;

  GleapUserSession({
    required this.userId,
    required this.userHash,
    this.name,
    this.email,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userId': userId,
        'userHash': userHash,
        'name': name,
        'email': email
      };
}

class Gleap {
  static const MethodChannel _channel = MethodChannel('gleap_sdk');

  /// ### initializeWithToken
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
    GleapUserSession? gleapUserSession,
  }) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint('initialize is not available for current operating system');
      return;
    }

    await _channel.invokeMethod(
      'initialize',
      {'token': token, 'gleapUserSession': gleapUserSession?.toJson()},
    );
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
  static Future<void> startFeedbackFlow() async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
          'startFeedbackFlow is not available for current operating system');
      return;
    }

    await _channel.invokeMethod('startFeedbackFlow');
  }

  /// ### sendSilentBugReport
  ///
  /// Send a silent bugreport in the background. Useful for automated ui tests.
  ///
  /// **Params**
  ///
  /// [description] Description of the bug
  ///
  /// [severity] Severity of the bug "LOW", "MIDDLE", "HIGH"
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS
  static Future<void> sendSilentBugReport({
    required String description,
    required Severity severity,
  }) async {
    if (!io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
          'sendSilentBugReport is not available for current operating system');
      return;
    }

    String severityVal = _getSeverityValue(severity);

    await _channel.invokeMethod(
      'sendSilentBugReport',
      {
        'description': description,
        'severity': severityVal,
      },
    );
  }

  /// ### identifyUserWith
  ///
  /// Updates a session's user data.
  ///
  /// **Params**
  ///
  /// [gleapUserSession] The updated user data.
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS
  static Future<void> identifyUserWith({
    required GleapUserSession gleapUserSession,
  }) async {
    if (!io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'identifyUserWith is not available for current operating system',
      );
      return;
    }
    await _channel.invokeMethod(
      'identifyUserWith',
      {
        'gleapUserSession': gleapUserSession.toJson(),
      },
    );
  }

  /// ### clearIdentity
  ///
  /// Clears a user session.
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS
  static Future<void> clearIdentity() async {
    if (!io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint('clearIdentity is not available for current operating system');
      return;
    }

    await _channel.invokeMethod('clearIdentity');
  }

  /// ### setApiUrl
  ///
  /// Sets the API url to your internal Gleap server. Please make sure that the server is reachable within the network
  /// If you use a http url pls add android:usesCleartextTraffic="true" to your main activity to allow cleartext traffic
  ///
  /// **Params**
  ///
  /// [apiUrl] Url of the internal Gleap server
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS
  static Future<void> setApiUrl({required String apiUrl}) async {
    if (!io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint('setApiUrl is not available for current operating system');
      return;
    }

    await _channel.invokeMethod('setApiUrl', {'apiUrl': apiUrl});
  }

  /// ### setWidgetUrl
  ///
  /// Sets a custom widget url.
  ///
  /// **Params**
  ///
  /// [widgetUrl] The custom widget url.
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS
  static Future<void> setWidgetUrl({required String widgetUrl}) async {
    if (!io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint('setWidgetUrl is not available for current operating system');
      return;
    }

    await _channel.invokeMethod('setWidgetUrl', {'widgetUrl': widgetUrl});
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
  /// Android, iOS
  static Future<void> setLanguage({required LanguageCode language}) async {
    if (!io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint('setLanguage is not available for current operating system');
      return;
    }

    String languageCodeVal = _getLanguageCodeValue(language);

    await _channel.invokeMethod('setLanguage', {'language': languageCodeVal});
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
  /// Android, iOS
  static Future<void> clearCustomData() async {
    if (!io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
          'clearCustomData is not available for current operating system');
      return;
    }

    await _channel.invokeMethod('clearCustomData');
  }

  /// ### setBugWillBeSentCallback
  ///
  /// This is called, when the Gleap flow is started
  ///
  /// **Params**
  ///
  /// [bugWillBeSentCallback] Is called when BB is opened
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS
  static Future<void> setBugWillBeSentCallback({
    required Function() callbackHandler,
  }) async {
    if (!io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
          'setBugWillBeSentCallback is not available for current operating system');
      return;
    }

    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'setBugWillBeSentCallback') {
        callbackHandler();
      }
    });
  }

  /// ### setBugSentCallback
  ///
  /// This method is triggered, when the Gleap flow is closed
  ///
  /// **Params**
  ///
  /// [gleapSentCallback] This callback is called when the flow is called
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS
  static Future<void> setBugSentCallback({
    required Function() callbackHandler,
  }) async {
    if (!io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'setBugSentCallback is not available for current operating system',
      );
      return;
    }

    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == "setBugSentCallback") {
        callbackHandler();
      }
    });
  }

  /// ### setBugSendingFailedCallback
  ///
  /// This method is triggered, when bug reporting failed
  ///
  /// **Params**
  ///
  /// [gleapSentCallback] This callback is called when the flow is called
  ///
  /// **Available Platforms**
  ///
  /// iOS
  static Future<void> setBugSendingFailedCallback({
    required Function() callbackHandler,
  }) async {
    if (!io.Platform.isIOS) {
      debugPrint(
        'setBugSendingFailedCallback is not available for current operating system',
      );
      return;
    }

    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == "setBugSendingFailedCallback") {
        callbackHandler();
      }
    });
  }

  /// ### setBitmapCallback
  ///
  /// Customize the way, the Bitmap is generated. If this is overritten, only the custom way is used
  ///
  /// **Params**
  ///
  /// [getBitmapCallback] Get the Bitmap
  ///
  /// **Available Platforms**
  ///
  /// Android
  static Future<void> setBitmapCallback({
    required Function() callbackHandler,
  }) async {
    if (!io.Platform.isAndroid) {
      debugPrint(
          'setBitmapCallback is not available for current operating system');
      return;
    }

    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == "setBitmapCallback") {
        callbackHandler();
      }
    });
  }

  /// ### logNetwork
  ///
  /// Log network traffic by logging it manually.
  ///
  /// **Params**
  ///
  /// [urlConnection] URL where the request is sent to
  ///
  /// [requestType] GET, POST, PUT, DELETE
  ///
  /// [status] Status of the response (e.g. 200, 404)
  ///
  /// [duration] Duration of the request
  ///
  /// [request] Add the data you want. e.g the body sent in the request
  ///
  /// [response] Response of the call. You can add just the information you want and need.
  ///
  /// **Available Platforms**
  ///
  /// Android
  static Future<void> logNetwork({
    required String urlConnection,
    required RequestType requestType,
    required int status,
    required int duration,
    required Map<String, dynamic> request,
    required Map<String, dynamic> response,
  }) async {
    if (!io.Platform.isAndroid) {
      debugPrint('logNetwork is not available for current operating system');
      return;
    }

    String requestTypeVal = _getRequestTypeValue(requestType);

    await _channel.invokeMethod(
      'logNetwork',
      {
        'urlConnection': urlConnection,
        'requestType': requestTypeVal,
        'status': status,
        'duration': duration,
        'request': request,
        'response': response,
      },
    );
  }

  /// ### startNetworkRecording
  ///
  /// Starts network recording.
  ///
  /// **Available Platforms**
  ///
  /// iOS
  static Future<void> startNetworkRecording() async {
    if (!io.Platform.isIOS) {
      debugPrint(
        'startNetworkRecording is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod('startNetworkRecording');
  }

  /// ### startNetworkRecordingForSessionConfiguration
  ///
  /// Starts network recording with a session configuration.
  ///
  /// [configuration] The NSURLSessionConfiguration which should be logged
  ///
  /// **Available Platforms**
  ///
  /// iOS
  static Future<void> startNetworkRecordingForSessionConfiguration() async {
    if (!io.Platform.isIOS) {
      debugPrint(
        'startNetworkRecordingForSessionConfiguration is not available for current operating system',
      );
      return;
    }

    // TODO add NSURLSessionConfiguration as params
  }

  /// ### stopNetworkRecording
  ///
  /// Stops network recording.
  ///
  /// **Available Platforms**
  ///
  /// iOS
  static Future<void> stopNetworkRecording() async {
    if (!io.Platform.isIOS) {
      debugPrint(
          'stopNetworkRecording is not available for current operating system');
      return;
    }

    await _channel.invokeMethod('stopNetworkRecording');
  }

  /// ### registerCustomAction
  ///
  /// Register a custom function, which can be called from the bug report flow
  ///
  /// **Params**
  ///
  /// [customAction] Implement the callback
  ///
  /// **Available Platforms**
  ///
  /// Android
  static Future<void> registerCustomAction({
    required Function() callbackHandler,
  }) async {
    if (!io.Platform.isAndroid) {
      debugPrint(
        'registerCustomAction is not available for current operating system',
      );
      return;
    }

    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == "registerCustomAction") {
        callbackHandler();
      }
    });
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

    await _channel.invokeMethod('logEvent', {'name': name, 'data': data});
  }

  /// ### addAttachmentWithName
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
  /// Android
  static Future<void> addAttachment({
    required File file,
  }) async {
    if (!io.Platform.isAndroid) {
      debugPrint('enableReplays is not available for current operating system');
      return;
    }

    await _channel.invokeMethod(
      'addAttachment',
      {'file': file},
    );
  }

  /// ### removeAllAttachments
  ///
  /// Removes all attachments
  ///
  /// **Available Platforms**
  ///
  /// Android
  static Future<void> removeAllAttachments() async {
    if (!io.Platform.isAndroid) {
      debugPrint(
        'removeAllAttachments is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod('removeAllAttachments');
  }

  /// ### openWidget
  ///
  /// Opens feedback widget
  ///
  /// **Available Platforms**
  ///
  /// Web
  static Future<void> openWidget() async {
    if (!kIsWeb) {
      debugPrint(
        'openWidget is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod('openWidget');
  }

  /// ### hideWidget
  ///
  /// Hides feedback widget
  ///
  /// **Available Platforms**
  ///
  /// Web
  static Future<void> hideWidget() async {
    if (!kIsWeb) {
      debugPrint(
        'hideWidget is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod('hideWidget');
  }
}
