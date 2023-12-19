// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

enum LogLevel { ERROR, WARNING, INFO }

String _getLogSevernityValue(LogLevel logSevernity) {
  switch (logSevernity) {
    case LogLevel.ERROR:
      return "ERROR";
    case LogLevel.WARNING:
      return "WARNING";
    case LogLevel.INFO:
      return "INFO";
    default:
      return "INFO";
  }
}

enum SurveyFormat { SURVEY_FULL, SURVEY }

String _getSurveyFormatValue(SurveyFormat surveyFormat) {
  switch (surveyFormat) {
    case SurveyFormat.SURVEY_FULL:
      return "survey_full";
    case SurveyFormat.SURVEY:
      return "survey";
    default:
      return "survey_full";
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

        if (currentCallback.takesArguments == false) {
          currentCallback.callbackHandler();
        } else {
          currentCallback.callbackHandler(callbackArgs);
        }
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

    _initCallbackHandler();

    await _channel.invokeMethod(
      'initialize',
      {'token': token},
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
  @deprecated
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

  /// ### startClassicForm
  ///
  /// Manually start the feedback form workflow.
  ///
  /// [GleapNotInitialisedException] thrown when Gleap is not initialised
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS, Web
  static Future<void> startClassicForm({
    required String formId,
    bool showBackButton = true,
  }) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
          'startClassicForm is not available for current operating system');
      return;
    }

    await _channel.invokeMethod(
      'startClassicForm',
      {'formId': formId, 'showBackButton': showBackButton},
    );
  }

  /// ### startConversation
  ///
  /// Manually start the conversation workflow.
  ///
  /// [GleapNotInitialisedException] thrown when Gleap is not initialised
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS, Web
  static Future<void> startConversation({bool showBackButton = true}) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
          'startConversation is not available for current operating system');
      return;
    }

    await _channel.invokeMethod(
      'startConversation',
      {'showBackButton': showBackButton},
    );
  }

  /// ### initialized
  ///
  /// Registers a callback for push messages
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static void initialized({
    required Function() callbackHandler,
  }) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'initialized is not available for current operating system',
      );
      return;
    }

    if (_callbackItems
        .where((CallbackItem element) => element.callbackName == 'initialized')
        .isNotEmpty) {
      debugPrint(
        'initialized is already registered.',
      );
      return;
    }

    _callbackItems.add(
      CallbackItem(
        callbackName: 'initialized',
        callbackHandler: callbackHandler,
        takesArguments: false,
      ),
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
  /// Android, iOS, Web
  static Future<void> attachNetworkLogs({
    required List<GleapNetworkLog> networkLogs,
  }) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
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

  /// ### trackEvent
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
  static Future<void> trackEvent({
    required String name,
    Map<String, dynamic>? data,
  }) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint('trackEvent is not available for current operating system');
      return;
    }

    data ??= <String, dynamic>{};

    await _channel.invokeMethod('trackEvent', {'name': name, 'data': data});
  }

  /// ### trackPage
  ///
  /// Tracks a custom page view
  ///
  /// **Params**
  ///
  /// [trackPage] Name of the page
  ///
  /// **Available Platforms**
  ///
  /// Android, iOS, Web
  static Future<void> trackPage({
    required String pageName,
  }) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint('trackPage is not available for current operating system');
      return;
    }

    await _channel.invokeMethod('trackPage', {'pageName': pageName});
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

  /// ### log
  ///
  /// Custom logs allow you to create logs in the Gleap activity log.
  /// There are three severnity types available for logs: ERROR, WARNING and INFO.
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<void> log({
    required String message,
    LogLevel logLevel = LogLevel.INFO,
  }) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'log is not available for current operating system',
      );
      return;
    }

    String preparedSevernity = _getLogSevernityValue(logLevel);

    await _channel.invokeMethod(
      'log',
      {
        'message': message,
        'logLevel': preparedSevernity,
      },
    );
  }

  /// ### setLogLevel
  ///
  /// It is possible to disable the default collection of console logs by calling the following method prior to the initialization of Gleap.
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<void> disableConsoleLog() async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'disableConsoleLog is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod('disableConsoleLog');
  }

  /// ### showFeedbackButton
  ///
  /// Hides or shows the feedback button
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<void> showFeedbackButton(bool visible) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'showFeedbackButton is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod('showFeedbackButton', {'visible': visible});
  }

  /// ### openChecklists
  ///
  /// Opens the checklist overview.
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<void> openChecklists({required bool showBackButton}) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'openChecklists is not available for current operating system',
      );
      return;
    }

    await _channel
        .invokeMethod('openChecklists', {'showBackButton': showBackButton});
  }

  /// ### openChecklist
  ///
  /// Opens an existing checklist.
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<void> openChecklist(
      {required String checklistId, required bool showBackButton}) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'openChecklist is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod('openChecklist',
        {'checklistId': checklistId, 'showBackButton': showBackButton});
  }

  /// ### startChecklist
  ///
  /// Starts a new checklist for the given outbound.
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<void> startChecklist(
      {required String outboundId, required bool showBackButton}) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'outboundId is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod('startChecklist',
        {'outboundId': outboundId, 'showBackButton': showBackButton});
  }

  /// ### openNews
  ///
  /// Opens the news feed in the widget
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<void> openNews({required bool showBackButton}) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'openNews is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod('openNews', {'showBackButton': showBackButton});
  }

  /// ### openNewsArticle
  ///
  /// Opens a news article in the widget
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<void> openNewsArticle(
      {required String articleId, required bool showBackButton}) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'openNewsArticle is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod('openNewsArticle',
        {'articleId': articleId, 'showBackButton': showBackButton});
  }

  /// ### openFeatureRequests
  ///
  /// Opens the feature request portal within the widget
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<void> openFeatureRequests(
      {required bool showBackButton}) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'openFeatureRequests is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod(
        'openFeatureRequests', {'showBackButton': showBackButton});
  }

  /// ### openHelpCenter
  ///
  /// Opens the help center within the widget
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<void> openHelpCenter({required bool showBackButton}) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'openHelpCenter is not available for current operating system',
      );
      return;
    }

    await _channel
        .invokeMethod('openHelpCenter', {'showBackButton': showBackButton});
  }

  /// ### openHelpCenterArticle
  ///
  /// Opens the help center article within the widget
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<void> openHelpCenterArticle(
      {required String articleId, required bool showBackButton}) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'openHelpCenter is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod('openHelpCenterArticle',
        {'articleId': articleId, 'showBackButton': showBackButton});
  }

  /// ### openHelpCenterCollection
  ///
  /// Opens the help center collection within the widget
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<void> openHelpCenterCollection(
      {required String collectionId, required bool showBackButton}) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'openHelpCenterCollection is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod('openHelpCenterCollection',
        {'collectionId': collectionId, 'showBackButton': showBackButton});
  }

  /// ### searchHelpCenter
  ///
  /// Searches the help center within the widget
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<void> searchHelpCenter(
      {required String term, required bool showBackButton}) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'searchHelpCenter is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod(
        'searchHelpCenter', {'term': term, 'showBackButton': showBackButton});
  }

  /// ### isUserIdentified
  ///
  /// Returns true if the user is identified
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<bool> isUserIdentified() async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'isUserIdentified is not available for current operating system',
      );
      return false;
    }

    return await _channel.invokeMethod('isUserIdentified');
  }

  /// ### getIdentity
  ///
  /// Returns the current identity
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<GleapUserProperty?> getIdentity() async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'getIdentity is not available for current operating system',
      );
      return null;
    }

    try {
      dynamic userProperty = await _channel.invokeMethod('getIdentity');

      return GleapUserProperty.fromJson(json.decode(json.encode(userProperty)));
    } catch (err) {
      return null;
    }
  }

  /// ### registerPushMessageGroup
  ///
  /// Registers a callback for push messages
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static void registerPushMessageGroup({
    required Function(String topic) callbackHandler,
  }) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'getIdentity is not available for current operating system',
      );
      return;
    }

    if (_callbackItems
        .where((CallbackItem element) =>
            element.callbackName == 'registerPushMessageGroup')
        .isNotEmpty) {
      debugPrint(
        'registerPushMessageGroup is already registered.',
      );
      return;
    }

    _callbackItems.add(
      CallbackItem(
        callbackName: 'registerPushMessageGroup',
        callbackHandler: callbackHandler,
      ),
    );
  }

  /// ### unregisterPushMessageGroup
  ///
  /// Unregisters a callback for push messages
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static void unregisterPushMessageGroup({
    required Function(String topic) callbackHandler,
  }) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'getIdentity is not available for current operating system',
      );
      return;
    }

    if (_callbackItems
        .where((CallbackItem element) =>
            element.callbackName == 'unregisterPushMessageGroup')
        .isNotEmpty) {
      debugPrint(
        'unregisterPushMessageGroup is already registered.',
      );
      return;
    }

    _callbackItems.add(
      CallbackItem(
        callbackName: 'unregisterPushMessageGroup',
        callbackHandler: callbackHandler,
      ),
    );
  }

  /// ### showSurvey
  ///
  /// Shows a survey
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<void> showSurvey({
    required String surveyId,
    SurveyFormat format = SurveyFormat.SURVEY,
  }) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'showSurvey is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod('showSurvey', {
      'surveyId': surveyId,
      'format': _getSurveyFormatValue(format),
    });
  }

  /// ### setTags
  ///
  /// Sets tags which will be passed with the Gleap tickets
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<void> setTags({required List<String> tags}) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'setTags is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod('setTags', {'tags': tags});
  }

  /// ### setDisableInAppNotifications
  ///
  /// Disables the in-app notifications
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<void> setDisableInAppNotifications({
    required bool disable,
  }) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'setDisableInAppNotifications is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod(
      'setDisableInAppNotifications',
      {'disable': disable},
    );
  }

  /// ### setDisableInAppNotifications
  ///
  /// Disables the in-app notifications
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<void> openConversation({required String shareToken}) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'openConversation is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod(
      'openConversation',
      {'shareToken': shareToken},
    );
  }

  /// ### handlePushNotification
  ///
  /// Handles a push notification
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<void> handlePushNotification({
    required Map<String, dynamic> data,
  }) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'handlePushNotification is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod('handlePushNotification', {
      'data': data,
    });
  }

  /// ### startBot
  ///
  /// Starts a bot
  ///
  /// **Available Platforms**
  ///
  /// Web, Android, iOS
  static Future<void> startBot({
    required String botId,
    bool showBackButton = true,
  }) async {
    if (!kIsWeb && !io.Platform.isAndroid && !io.Platform.isIOS) {
      debugPrint(
        'startBot is not available for current operating system',
      );
      return;
    }

    await _channel.invokeMethod('startBot', {
      'botId': botId,
      'showBackButton': showBackButton,
    });
  }
}
