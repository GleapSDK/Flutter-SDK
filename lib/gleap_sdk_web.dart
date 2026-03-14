import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
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

    registerEvents(channel);
  }

  static void registerEvents(MethodChannel channel) {
    void open(JSAny? data) {
      channel.invokeMethod('widgetOpened');
    }
    GleapJsSdkHelper.registerEvents('open'.toJS, open.toJS);

    void close(JSAny? data) {
      channel.invokeMethod('widgetClosed');
    }
    GleapJsSdkHelper.registerEvents('close'.toJS, close.toJS);

    void feedbackSent(JSAny? data) {
      channel.invokeMethod('feedbackSent');
    }
    GleapJsSdkHelper.registerEvents('feedback-sent'.toJS, feedbackSent.toJS);

    void outboundSent(JSAny? data) {
      channel.invokeMethod('outboundSent');
    }
    GleapJsSdkHelper.registerEvents('outbound-sent'.toJS, outboundSent.toJS);

    void errorWhileSending(JSAny? data) {
      channel.invokeMethod('feedbackSendingFailed');
    }
    GleapJsSdkHelper.registerEvents(
        'error-while-sending'.toJS, errorWhileSending.toJS);

    void initialized(JSAny? data) {
      channel.invokeMethod('initialized');
    }
    GleapJsSdkHelper.registerEvents('initialized'.toJS, initialized.toJS);

    void feedbackFlowStarted(JSAny? data) {
      final String strifiedData =
          GleapJsSdkHelper.stringify(data!).toDart;

      channel.invokeMethod(
        'feedbackFlowStarted',
        jsonDecode(strifiedData),
      );
    }
    GleapJsSdkHelper.registerEvents(
        'flow-started'.toJS, feedbackFlowStarted.toJS);

    void customActionCalled(JSAny? data) {
      final String strifiedData =
          GleapJsSdkHelper.stringify(data!).toDart;
      final Map<String, dynamic> parsed = jsonDecode(strifiedData);

      channel.invokeMethod(
        'customActionTriggered',
        <String, dynamic>{'name': parsed['name']},
      );
    }
    GleapJsSdkHelper.registerCustomAction(customActionCalled.toJS);

    void registerPushMessageGroup(JSAny? data) {
      final String strifiedData =
          GleapJsSdkHelper.stringify(data!).toDart;
      channel.invokeMethod('registerPushMessageGroup', jsonDecode(strifiedData));
    }
    GleapJsSdkHelper.registerEvents(
        'register-pushmessage-group'.toJS, registerPushMessageGroup.toJS);

    void unregisterPushMessageGroup(JSAny? data) {
      final String strifiedData =
          GleapJsSdkHelper.stringify(data!).toDart;
      channel.invokeMethod(
          'unregisterPushMessageGroup', jsonDecode(strifiedData));
    }
    GleapJsSdkHelper.registerEvents(
        'unregister-pushmessage-group'.toJS, unregisterPushMessageGroup.toJS);

    void toolExecution(JSAny? data) {
      final String strifiedData =
          GleapJsSdkHelper.stringify(data!).toDart;

      channel.invokeMethod('toolExecution', strifiedData);
    }
    GleapJsSdkHelper.registerEvents(
        'tool-execution'.toJS, toolExecution.toJS);
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

      case 'askAI':
        return askAI(
            question: call.arguments['question'],
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

      case 'setNotificationContainerOffset':
        return setNotificationContainerOffset(
          x: call.arguments['x'],
          y: call.arguments['y'],
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
    GleapJsSdkHelper.initialize(token.toJS);
  }

  Future<void> identify({
    required String userId,
    dynamic userProperties,
    String? userHash,
  }) async {
    String stringifiedHashMap = jsonEncode(userProperties);

    GleapJsSdkHelper.identify(
      userId.toJS,
      stringifiedHashMap.toJS,
      userHash?.toJS,
    );
  }

  Future<void> updateContact({dynamic userProperties}) async {
    String stringifiedHashMap = jsonEncode(userProperties);

    GleapJsSdkHelper.updateContact(stringifiedHashMap.toJS);
  }

  Future<void> clearIdentity() async {
    GleapJsSdkHelper.clearIdentity();
  }

  Future<void> preFillForm({required dynamic formData}) async {
    String stringifiedHashMap = jsonEncode(formData);

    GleapJsSdkHelper.preFillForm(stringifiedHashMap.toJS);
  }

  Future<void> attachCustomData({required dynamic customData}) async {
    String stringifiedHashMap = jsonEncode(customData);

    GleapJsSdkHelper.attachCustomData(stringifiedHashMap.toJS);
  }

  Future<void> setCustomData({
    required String key,
    required String value,
  }) async {
    GleapJsSdkHelper.setCustomData(key.toJS, value.toJS);
  }

  Future<void> removeCustomData({required String key}) async {
    GleapJsSdkHelper.removeCustomData(key.toJS);
  }

  Future<void> clearCustomData() async {
    GleapJsSdkHelper.clearCustomData();
  }

  Future<void> trackEvent({
    required String name,
    dynamic data,
  }) async {
    String stringifiedHashMap = jsonEncode(data);

    GleapJsSdkHelper.trackEvent(name.toJS, stringifiedHashMap.toJS);
  }

  Future<void> sendSilentCrashReport({
    required String description,
    required String severity,
    dynamic excludeData = const {},
  }) async {
    String stringifiedHashMap = jsonEncode(excludeData);

    GleapJsSdkHelper.sendSilentCrashReport(
      description.toJS,
      severity.toJS,
      stringifiedHashMap.toJS,
    );
  }

  Future<void> openWidget() async {
    GleapJsSdkHelper.open();
  }

  Future<void> closeWidget() async {
    GleapJsSdkHelper.close();
  }

  Future<void> startFeedbackFlow({
    required String action,
    required bool showBackButton,
  }) async {
    GleapJsSdkHelper.startFeedbackFlow(action.toJS, showBackButton.toJS);
  }

  Future<void> startConversation() async {
    GleapJsSdkHelper.startConversation();
  }

  Future<void> setLanguage({required String language}) async {
    GleapJsSdkHelper.setLanguage(language.toJS);
  }

  Future<bool> isOpened() async {
    return GleapJsSdkHelper.isOpened().toDart;
  }

  Future<void> setFrameUrl({required String url}) async {
    GleapJsSdkHelper.setFrameUrl(url.toJS);
  }

  Future<void> setApiUrl({required String url}) async {
    GleapJsSdkHelper.setApiUrl(url.toJS);
  }

  Future<void> log({required String message, String? logLevel}) async {
    GleapJsSdkHelper.log(message.toJS, logLevel?.toJS);
  }

  Future<void> disableConsoleLog() async {
    GleapJsSdkHelper.disableConsoleLog();
  }

  Future<void> attachNetworkLogs({
    required List<dynamic> networkLogs,
  }) async {
    GleapJsSdkHelper.attachNetworkLogs(
      json.encode(networkLogs).toJS,
    );
  }

  Future<void> showFeedbackButton({required bool visible}) async {
    GleapJsSdkHelper.showFeedbackButton(visible.toJS);
  }

  Future<void> openChecklists({required bool showBackButton}) async {
    GleapJsSdkHelper.openChecklists(showBackButton.toJS);
  }

  Future<void> openChecklist({
    required String checklistId,
    required bool showBackButton,
  }) async {
    GleapJsSdkHelper.openChecklist(checklistId.toJS, showBackButton.toJS);
  }

  Future<void> startChecklist({
    required String outboundId,
    required bool showBackButton,
  }) async {
    GleapJsSdkHelper.startChecklist(outboundId.toJS, showBackButton.toJS);
  }

  Future<void> openNews({required bool showBackButton}) async {
    GleapJsSdkHelper.openNews(showBackButton.toJS);
  }

  Future<void> openNewsArticle({
    required String articleId,
    required bool showBackButton,
  }) async {
    GleapJsSdkHelper.openNewsArticle(articleId.toJS, showBackButton.toJS);
  }

  Future<void> openFeatureRequests({required bool showBackButton}) async {
    GleapJsSdkHelper.openFeatureRequests(showBackButton.toJS);
  }

  Future<void> openHelpCenter({required bool showBackButton}) async {
    GleapJsSdkHelper.openHelpCenter(showBackButton.toJS);
  }

  Future<void> openHelpCenterArticle({
    required String articleId,
    required bool showBackButton,
  }) async {
    GleapJsSdkHelper.openHelpCenterArticle(articleId.toJS, showBackButton.toJS);
  }

  Future<void> askAI({
    required String question,
    required bool showBackButton,
  }) async {
    GleapJsSdkHelper.askAI(question.toJS, showBackButton.toJS);
  }

  Future<void> openHelpCenterCollection({
    required String collectionId,
    required bool showBackButton,
  }) async {
    GleapJsSdkHelper.openHelpCenterCollection(
      collectionId.toJS,
      showBackButton.toJS,
    );
  }

  Future<void> searchHelpCenter({
    required String term,
    required bool showBackButton,
  }) async {
    GleapJsSdkHelper.searchHelpCenter(term.toJS, showBackButton.toJS);
  }

  Future<bool> isUserIdentified() async {
    return GleapJsSdkHelper.isUserIdentified().toDart;
  }

  Future<dynamic> getIdentity() async {
    final JSAny? identity = GleapJsSdkHelper.getIdentity();
    if (identity == null) return null;
    final String strifiedData = GleapJsSdkHelper.stringify(identity).toDart;

    return jsonDecode(strifiedData);
  }

  Future<void> showSurvey({
    required String surveyId,
    required String format,
  }) async {
    GleapJsSdkHelper.showSurvey(surveyId.toJS, format.toJS);
  }

  Future<void> setTags({required List<dynamic> tags}) async {
    GleapJsSdkHelper.setTags(tags.jsify() as JSArray);
  }

  Future<void> setDisableInAppNotifications({required bool disable}) async {
    GleapJsSdkHelper.setDisableInAppNotifications(disable.toJS);
  }

  Future<void> setNotificationContainerOffset({
    required num x,
    required num y,
  }) async {
    // Intentionally left blank – not supported in JS SDK.
  }

  Future<void> setNetworkLogsBlacklist({
    required List<dynamic> networkLogBlacklist,
  }) async {
    GleapJsSdkHelper.setNetworkLogsBlacklist(
            networkLogBlacklist.jsify() as JSArray);
  }

  Future<void> setNetworkLogPropsToIgnore({
    required List<dynamic> filters,
  }) async {
    GleapJsSdkHelper.setNetworkLogPropsToIgnore(filters.jsify() as JSArray);
  }

  Future<void> setAiTools({required List<dynamic> tools}) async {
    GleapJsSdkHelper.setAiTools(tools.jsify()!);
  }

  Future<void> setTicketAttribute({
    required String key,
    required dynamic value,
  }) async {
    GleapJsSdkHelper.setTicketAttribute(key.toJS, (value as Object?)?.jsify());
  }

  Future<void> unsetTicketAttribute({required String key}) async {
    GleapJsSdkHelper.unsetTicketAttribute(key.toJS);
  }

  Future<void> clearTicketAttributes() async {
    GleapJsSdkHelper.clearTicketAttributes();
  }

  Future<void> startBot({required String botId}) async {
    GleapJsSdkHelper.startBot(botId.toJS);
  }

  Future<void> openConversation({required String shareToken}) async {
    GleapJsSdkHelper.openConversation(shareToken.toJS);
  }

  Future<void> openConversations() async {
    GleapJsSdkHelper.openConversations();
  }

  Future<void> startClassicForm({required String formId}) async {
    GleapJsSdkHelper.startClassicForm(formId.toJS);
  }
}
