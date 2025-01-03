import 'dart:async';
import 'dart:convert';
import 'dart:js';
import 'dart:js_util';
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
      channel.invokeMethod('widgetOpened');
    });
    GleapJsSdkHelper.registerEvents('open', open);

    void Function(dynamic data) close = allowInterop((dynamic data) {
      channel.invokeMethod('widgetClosed');
    });
    GleapJsSdkHelper.registerEvents('close', close);

    void Function(dynamic data) feedbackSent = allowInterop((dynamic data) {
      channel.invokeMethod('feedbackSent');
    });
    GleapJsSdkHelper.registerEvents('feedback-sent', feedbackSent);

    void Function(dynamic data) outboundSent = allowInterop((dynamic data) {
      channel.invokeMethod('outboundSent');
    });
    GleapJsSdkHelper.registerEvents('outbound-sent', outboundSent);

    void Function(dynamic data) errorWhileSending =
        allowInterop((dynamic data) {
      channel.invokeMethod('feedbackSendingFailed');
    });
    GleapJsSdkHelper.registerEvents('error-while-sending', errorWhileSending);

    void Function(dynamic data) initialized = allowInterop((dynamic data) {
      channel.invokeMethod('initialized');
    });
    GleapJsSdkHelper.registerEvents('initialized', initialized);

    void Function(dynamic data) feedbackFlowStarted =
        allowInterop((dynamic data) {
      final String strifiedData = GleapJsSdkHelper.stringify(data as Object);

      channel.invokeMethod(
        'feedbackFlowStarted',
        jsonDecode(strifiedData),
      );
    });
    GleapJsSdkHelper.registerEvents('flow-started', feedbackFlowStarted);

    void Function(dynamic data) customActionCalled =
        allowInterop((dynamic data) {
      channel.invokeMethod(
        'customActionTriggered',
        <String, dynamic>{'name': data.name},
      );
    });
    GleapJsSdkHelper.registerCustomAction(customActionCalled);

    void Function(dynamic data) registerPushMessageGroup =
        allowInterop((dynamic data) {
      channel.invokeMethod('registerPushMessageGroup', data);
    });
    GleapJsSdkHelper.registerEvents(
        'register-pushmessage-group', registerPushMessageGroup);

    void Function(dynamic data) unregisterPushMessageGroup =
        allowInterop((dynamic data) {
      channel.invokeMethod('unregisterPushMessageGroup', data);
    });
    GleapJsSdkHelper.registerEvents(
        'unregister-pushmessage-group', unregisterPushMessageGroup);

    void Function(dynamic data) toolExecution = allowInterop((dynamic data) {
      final String strifiedData = GleapJsSdkHelper.stringify(data as Object);

      channel.invokeMethod('toolExecution', strifiedData);
    });
    GleapJsSdkHelper.registerEvents('tool-execution', toolExecution);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'initialize':
        return initialize(token: call.arguments['token']);

      case 'identify':
      case 'identifyContact':
        return identify(
          userId: call.arguments['userId'],
          userProperties: call.arguments['userProperties'],
          userHash: call.arguments['userHash'],
        );

      case 'updateContact':
        return updateContact(userProperties: call.arguments['userProperties']);

      case 'clearIdentity':
        return clearIdentity();

      case 'attachCustomData':
        return attachCustomData(
          customData: call.arguments['customData'],
        );

      case 'preFillForm':
        return preFillForm(
          formData: call.arguments['formData'],
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

      case 'trackEvent':
        return trackEvent(
          name: call.arguments['name'],
          data: call.arguments['data'],
        );

      case 'trackPage':
        return trackEvent(name: "pageView", data: <String, dynamic>{
          'page': call.arguments['pageName'],
        });

      case 'sendSilentCrashReport':
        return sendSilentCrashReport(
          description: call.arguments['description'],
          severity: call.arguments['severity'],
          excludeData: call.arguments['excludeData'],
        );
      case 'openWidget':
        return openWidget();

      case 'closeWidget':
        return closeWidget();

      case 'startFeedbackFlow':
        return startFeedbackFlow(
          action: call.arguments['action'],
          showBackButton: call.arguments['showBackButton'],
        );

      case 'startConversation':
        return startConversation();

      case 'setLanguage':
        return setLanguage(language: call.arguments['language']);

      case 'isOpened':
        return isOpened();

      case 'setFrameUrl':
        return setFrameUrl(url: call.arguments['url']);

      case 'setApiUrl':
        return setApiUrl(url: call.arguments['url']);

      case 'log':
        return log(
          message: call.arguments['message'],
          logLevel: call.arguments['logLevel'],
        );
      case 'disableConsoleLog':
        return disableConsoleLog();

      case 'attachNetworkLogs':
        return attachNetworkLogs(networkLogs: call.arguments['networkLogs']);

      case 'showFeedbackButton':
        return showFeedbackButton(visible: call.arguments['visible']);

      case 'openChecklists':
        return openChecklists(showBackButton: call.arguments['showBackButton']);

      case 'openChecklist':
        return openChecklist(
            checklistId: call.arguments['checklistId'],
            showBackButton: call.arguments['showBackButton']);

      case 'startChecklist':
        return startChecklist(
            outboundId: call.arguments['outboundId'],
            showBackButton: call.arguments['showBackButton']);

      case 'openNews':
        return openNews(showBackButton: call.arguments['showBackButton']);

      case 'openNewsArticle':
        return openNewsArticle(
            articleId: call.arguments['articleId'],
            showBackButton: call.arguments['showBackButton']);

      case 'openHelpCenter':
        return openHelpCenter(showBackButton: call.arguments['showBackButton']);

      case 'openHelpCenterArticle':
        return openHelpCenterArticle(
            articleId: call.arguments['articleId'],
            showBackButton: call.arguments['showBackButton']);

      case 'openHelpCenterCollection':
        return openHelpCenterCollection(
            collectionId: call.arguments['collectionId'],
            showBackButton: call.arguments['showBackButton']);

      case 'searchHelpCenter':
        return searchHelpCenter(
            term: call.arguments['term'],
            showBackButton: call.arguments['showBackButton']);

      case 'openFeatureRequests':
        return openFeatureRequests(
            showBackButton: call.arguments['showBackButton']);

      case 'isUserIdentified':
        return isUserIdentified();

      case 'getIdentity':
        return getIdentity();

      case 'showSurvey':
        return showSurvey(
          surveyId: call.arguments['surveyId'],
          format: call.arguments['format'],
        );

      case 'setTags':
        return setTags(tags: call.arguments['tags']);

      case 'setDisableInAppNotifications':
        return setDisableInAppNotifications(
          disable: call.arguments['disable'],
        );

      case 'setNetworkLogsBlacklist':
        return setNetworkLogsBlacklist(
          networkLogBlacklist: call.arguments['blacklist'],
        );

      case 'setNetworkLogPropsToIgnore':
        return setNetworkLogPropsToIgnore(
          filters: call.arguments['networkLogPropsToIgnore'],
        );

      case 'setAiTools':
        return setAiTools(tools: call.arguments['tools']);

      case 'setTicketAttribute':
        return setTicketAttribute(
          key: call.arguments['key'],
          value: call.arguments['value'],
        );

      case 'unsetTicketAttribute':
        return unsetTicketAttribute(key: call.arguments['key']);

      case 'clearTicketAttributes':
        return clearTicketAttributes();

      case 'startBot':
        return startBot(botId: call.arguments['botId']);

      case 'openConversation':
        return openConversation(shareToken: call.arguments['shareToken']);

      case 'openConversations':
        return openConversations();

      case 'startClassicForm':
        return startClassicForm(formId: call.arguments['formId']);

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
    String? userHash,
  }) async {
    String? stringifiedHashMap = jsonEncode(userProperties);

    await GleapJsSdkHelper.identify(userId, stringifiedHashMap, userHash);
  }

  Future<void> updateContact({dynamic userProperties}) async {
    String? stringifiedHashMap = jsonEncode(userProperties);

    await GleapJsSdkHelper.updateContact(stringifiedHashMap);
  }

  Future<void> clearIdentity() async {
    await GleapJsSdkHelper.clearIdentity();
  }

  Future<void> preFillForm({required dynamic formData}) async {
    String? stringifiedHashMap = jsonEncode(formData);

    await GleapJsSdkHelper.preFillForm(stringifiedHashMap);
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

  Future<void> trackEvent({
    required String name,
    dynamic data,
  }) async {
    String? stringifiedHashMap = jsonEncode(data);

    await GleapJsSdkHelper.trackEvent(name, stringifiedHashMap);
  }

  Future<void> sendSilentCrashReport({
    required String description,
    required String severity,
    dynamic excludeData = const {},
  }) async {
    String? stringifiedHashMap = jsonEncode(excludeData);

    await GleapJsSdkHelper.sendSilentCrashReport(
      description,
      severity,
      stringifiedHashMap,
    );
  }

  Future<void> openWidget() async {
    await GleapJsSdkHelper.open();
  }

  Future<void> closeWidget() async {
    await GleapJsSdkHelper.close();
  }

  Future<void> startFeedbackFlow({
    required String action,
    required bool showBackButton,
  }) async {
    await GleapJsSdkHelper.startFeedbackFlow(action, showBackButton);
  }

  Future<void> startConversation() async {
    await GleapJsSdkHelper.startConversation();
  }

  Future<void> setLanguage({required String language}) async {
    await GleapJsSdkHelper.setLanguage(language);
  }

  Future<bool> isOpened() async {
    return await GleapJsSdkHelper.isOpened();
  }

  Future<void> setFrameUrl({required String url}) async {
    await GleapJsSdkHelper.setFrameUrl(url);
  }

  Future<void> setApiUrl({required String url}) async {
    await GleapJsSdkHelper.setApiUrl(url);
  }

  Future<void> log({required String message, String? logLevel}) async {
    await GleapJsSdkHelper.log(message, logLevel);
  }

  Future<void> disableConsoleLog() async {
    await GleapJsSdkHelper.disableConsoleLog();
  }

  Future<void> attachNetworkLogs({
    required List<dynamic> networkLogs,
  }) async {
    await GleapJsSdkHelper.attachNetworkLogs(
      json.encode(networkLogs),
    );
  }

  Future<void> showFeedbackButton({required bool visible}) {
    return GleapJsSdkHelper.showFeedbackButton(visible);
  }

  Future<void> openChecklists({required bool showBackButton}) {
    return GleapJsSdkHelper.openChecklists(showBackButton);
  }

  Future<void> openChecklist({
    required String checklistId,
    required bool showBackButton,
  }) {
    return GleapJsSdkHelper.openChecklist(checklistId, showBackButton);
  }

  Future<void> startChecklist({
    required String outboundId,
    required bool showBackButton,
  }) {
    return GleapJsSdkHelper.startChecklist(outboundId, showBackButton);
  }

  Future<void> openNews({required bool showBackButton}) {
    return GleapJsSdkHelper.openNews(showBackButton);
  }

  Future<void> openNewsArticle({
    required String articleId,
    required bool showBackButton,
  }) {
    return GleapJsSdkHelper.openNewsArticle(articleId, showBackButton);
  }

  Future<void> openFeatureRequests({required bool showBackButton}) {
    return GleapJsSdkHelper.openFeatureRequests(showBackButton);
  }

  Future<void> openHelpCenter({required bool showBackButton}) {
    return GleapJsSdkHelper.openHelpCenter(showBackButton);
  }

  Future<void> openHelpCenterArticle({
    required String articleId,
    required bool showBackButton,
  }) {
    return GleapJsSdkHelper.openHelpCenterArticle(articleId, showBackButton);
  }

  Future<void> openHelpCenterCollection({
    required String collectionId,
    required bool showBackButton,
  }) {
    return GleapJsSdkHelper.openHelpCenterCollection(
      collectionId,
      showBackButton,
    );
  }

  Future<void> searchHelpCenter({
    required String term,
    required bool showBackButton,
  }) {
    return GleapJsSdkHelper.searchHelpCenter(term, showBackButton);
  }

  Future<bool> isUserIdentified() async {
    return await GleapJsSdkHelper.isUserIdentified();
  }

  Future<dynamic> getIdentity() async {
    final dynamic identity = await GleapJsSdkHelper.getIdentity();
    final String strifiedData = GleapJsSdkHelper.stringify(identity);

    return jsonDecode(strifiedData);
  }

  Future<void> showSurvey({
    required String surveyId,
    required String format,
  }) async {
    return GleapJsSdkHelper.showSurvey(surveyId, format);
  }

  Future<void> setTags({required List<dynamic> tags}) async {
    return GleapJsSdkHelper.setTags(tags);
  }

  Future<void> setDisableInAppNotifications({required bool disable}) async {
    return GleapJsSdkHelper.setDisableInAppNotifications(disable);
  }

  Future<void> setNetworkLogsBlacklist({
    required List<dynamic> networkLogBlacklist,
  }) async {
    return GleapJsSdkHelper.setNetworkLogsBlacklist(networkLogBlacklist);
  }

  Future<void> setNetworkLogPropsToIgnore({
    required List<dynamic> filters,
  }) async {
    return GleapJsSdkHelper.setNetworkLogPropsToIgnore(filters);
  }

  Future<void> setAiTools({required List<dynamic> tools}) async {
    return GleapJsSdkHelper.setAiTools(jsify(tools));
  }

  Future<void> setTicketAttribute({
    required String key,
    required dynamic value,
  }) async {
    return GleapJsSdkHelper.setTicketAttribute(key, value);
  }

  Future<void> unsetTicketAttribute({required String key}) async {
    return GleapJsSdkHelper.unsetTicketAttribute(key);
  }

  Future<void> clearTicketAttributes() async {
    return GleapJsSdkHelper.clearTicketAttributes();
  }

  Future<void> startBot({required String botId}) async {
    return GleapJsSdkHelper.startBot(botId);
  }

  Future<void> openConversation({required String shareToken}) async {
    return GleapJsSdkHelper.openConversation(shareToken);
  }

  Future<void> openConversations() async {
    return GleapJsSdkHelper.openConversations();
  }

  Future<void> startClassicForm({required String formId}) async {
    return GleapJsSdkHelper.startClassicForm(formId);
  }
}
