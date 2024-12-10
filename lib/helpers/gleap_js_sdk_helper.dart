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

@JS('window.Gleap.updateContact')
external Future<void> updateContact(
  dynamic customerData,
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

@JS('window.Gleap.trackEvent')
external Future<void> trackEvent(String event, String? data);

@JS('window.Gleap.sendSilentCrashReport')
external Future<void> sendSilentCrashReport(
  String description,
  String severity,
  String excludeData,
);

@JS('window.Gleap.open')
external Future<void> open();

@JS('window.Gleap.close')
external Future<void> close();

@JS('window.Gleap.startFeedbackFlow')
external Future<void> startFeedbackFlow(String flow, bool showBackButton);

@JS('window.Gleap.startConversation')
external Future<void> startConversation();

@JS('window.Gleap.setLanguage')
external Future<void> setLanguage(String language);

@JS('window.Gleap.isOpened')
external Future<bool> isOpened();

@JS('window.Gleap.setFrameUrl')
external Future<void> setFrameUrl(String url);

@JS('window.Gleap.setApiUrl')
external Future<void> setApiUrl(String url);

@JS('window.Gleap.log')
external Future<void> log(String message, String? logLevel);

@JS('window.Gleap.disableConsoleLogOverwrite')
external Future<void> disableConsoleLog();

@JS('window.Gleap.attachNetworkLogs')
external Future<void> attachNetworkLogs(String networkLogs);

@JS('window.Gleap.showFeedbackButton')
external Future<void> showFeedbackButton(bool visible);

@JS('window.Gleap.openChecklists')
external Future<void> openChecklists(bool showBackButton);

@JS('window.Gleap.openChecklist')
external Future<void> openChecklist(String checklistId, bool showBackButton);

@JS('window.Gleap.startChecklist')
external Future<void> startChecklist(String outboundId, bool showBackButton);

@JS('window.Gleap.openNews')
external Future<void> openNews(bool showBackButton);

@JS('window.Gleap.openNewsArticle')
external Future<void> openNewsArticle(String articleId, bool showBackButton);

@JS('window.Gleap.openFeatureRequests')
external Future<void> openFeatureRequests(bool showBackButton);

@JS('window.Gleap.openHelpCenter')
external Future<void> openHelpCenter(bool showBackButton);

@JS('window.Gleap.openHelpCenterArticle')
external Future<void> openHelpCenterArticle(
    String articleId, bool showBackButton);

@JS('window.Gleap.openHelpCenterCollection')
external Future<void> openHelpCenterCollection(
    String collectionId, bool showBackButton);

@JS('window.Gleap.searchHelpCenter')
external Future<void> searchHelpCenter(String term, bool showBackButton);

@JS('window.Gleap.isUserIdentified')
external Future<bool> isUserIdentified();

@JS('window.Gleap.getIdentity')
external Future<dynamic> getIdentity();

@JS('window.Gleap.showSurvey')
external Future<void> showSurvey(String surveyId, String format);

@JS('window.Gleap.setTags')
external Future<void> setTags(List<dynamic> tags);

@JS('window.Gleap.setDisableInAppNotifications')
external Future<void> setDisableInAppNotifications(bool disable);

@JS('JSON.stringify')
external String stringify(Object obj);

@JS('window.Gleap.setNetworkLogsBlacklist')
external Future<void> setNetworkLogsBlacklist(
    List<dynamic> networkLogBlacklist);

@JS('window.Gleap.setNetworkLogPropsToIgnore')
external Future<void> setNetworkLogPropsToIgnore(List<dynamic> filters);

@JS('window.Gleap.setAiTools')
external Future<void> setAiTools(List<dynamic> tools);

@JS('window.Gleap.setTicketAttribute')
external Future<void> setTicketAttribute(String key, dynamic value);

@JS('window.Gleap.unsetTicketAttribute')
external Future<void> unsetTicketAttribute(String key);

@JS('window.Gleap.clearTicketAttributes')
external Future<void> clearTicketAttributes();

@JS('window.Gleap.startBot')
external Future<void> startBot(String botId);

@JS('window.Gleap.openConversation')
external Future<void> openConversation(String shareToken);

@JS('window.Gleap.openConversations')
external Future<void> openConversations();

@JS('window.Gleap.startClassicForm')
external Future<void> startClassicForm(String formId);
