@JS()
library gleap;

import 'dart:js_interop';

@JS('window.Gleap.initialize')
external void initialize(JSString token);

@JS('window.Gleap.identify')
external void identify(
  JSString userId,
  JSString? userData,
  JSString? userHash,
);

@JS('window.Gleap.updateContact')
external void updateContact(JSAny? customerData);

@JS('window.Gleap.clearIdentity')
external void clearIdentity();

@JS('window.Gleap.attachCustomData')
external void attachCustomData(JSString customData);

@JS('window.Gleap.preFillForm')
external void preFillForm(JSString formData);

@JS('window.Gleap.setCustomData')
external void setCustomData(JSString key, JSString value);

@JS('window.Gleap.removeCustomData')
external void removeCustomData(JSString key);

@JS('window.Gleap.clearCustomData')
external void clearCustomData();

@JS('Gleap.registerCustomAction')
external void registerCustomAction(JSFunction callbackHandler);

@JS('window.Gleap.on')
external void registerEvents(JSString name, JSFunction callbackHandler);

@JS('window.Gleap.trackEvent')
external void trackEvent(JSString event, JSString? data);

@JS('window.Gleap.sendSilentCrashReport')
external void sendSilentCrashReport(
  JSString description,
  JSString severity,
  JSString excludeData,
);

@JS('window.Gleap.open')
external void open();

@JS('window.Gleap.close')
external void close();

@JS('window.Gleap.startFeedbackFlow')
external void startFeedbackFlow(JSString flow, JSBoolean showBackButton);

@JS('window.Gleap.startConversation')
external void startConversation();

@JS('window.Gleap.setLanguage')
external void setLanguage(JSString language);

@JS('window.Gleap.isOpened')
external JSBoolean isOpened();

@JS('window.Gleap.setFrameUrl')
external void setFrameUrl(JSString url);

@JS('window.Gleap.setApiUrl')
external void setApiUrl(JSString url);

@JS('window.Gleap.log')
external void log(JSString message, JSString? logLevel);

@JS('window.Gleap.disableConsoleLogOverwrite')
external void disableConsoleLog();

@JS('window.Gleap.attachNetworkLogs')
external void attachNetworkLogs(JSString networkLogs);

@JS('window.Gleap.showFeedbackButton')
external void showFeedbackButton(JSBoolean visible);

@JS('window.Gleap.openChecklists')
external void openChecklists(JSBoolean showBackButton);

@JS('window.Gleap.openChecklist')
external void openChecklist(JSString checklistId, JSBoolean showBackButton);

@JS('window.Gleap.startChecklist')
external void startChecklist(JSString outboundId, JSBoolean showBackButton);

@JS('window.Gleap.openNews')
external void openNews(JSBoolean showBackButton);

@JS('window.Gleap.openNewsArticle')
external void openNewsArticle(JSString articleId, JSBoolean showBackButton);

@JS('window.Gleap.openFeatureRequests')
external void openFeatureRequests(JSBoolean showBackButton);

@JS('window.Gleap.openHelpCenter')
external void openHelpCenter(JSBoolean showBackButton);

@JS('window.Gleap.openHelpCenterArticle')
external void openHelpCenterArticle(
    JSString articleId, JSBoolean showBackButton);

@JS('window.Gleap.askAI')
external void askAI(JSString question, JSBoolean showBackButton);

@JS('window.Gleap.openHelpCenterCollection')
external void openHelpCenterCollection(
    JSString collectionId, JSBoolean showBackButton);

@JS('window.Gleap.searchHelpCenter')
external void searchHelpCenter(JSString term, JSBoolean showBackButton);

@JS('window.Gleap.isUserIdentified')
external JSBoolean isUserIdentified();

@JS('window.Gleap.getIdentity')
external JSAny? getIdentity();

@JS('window.Gleap.showSurvey')
external void showSurvey(JSString surveyId, JSString format);

@JS('window.Gleap.setTags')
external void setTags(JSArray tags);

@JS('window.Gleap.setDisableInAppNotifications')
external void setDisableInAppNotifications(JSBoolean disable);

@JS('JSON.stringify')
external JSString stringify(JSAny obj);

@JS('window.Gleap.setNetworkLogsBlacklist')
external void setNetworkLogsBlacklist(JSArray networkLogBlacklist);

@JS('window.Gleap.setNetworkLogPropsToIgnore')
external void setNetworkLogPropsToIgnore(JSArray filters);

@JS('window.Gleap.setAiTools')
external void setAiTools(JSAny tools);

@JS('window.Gleap.setTicketAttribute')
external void setTicketAttribute(JSString key, JSAny? value);

@JS('window.Gleap.unsetTicketAttribute')
external void unsetTicketAttribute(JSString key);

@JS('window.Gleap.clearTicketAttributes')
external void clearTicketAttributes();

@JS('window.Gleap.startBot')
external void startBot(JSString botId);

@JS('window.Gleap.openConversation')
external void openConversation(JSString shareToken);

@JS('window.Gleap.openConversations')
external void openConversations();

@JS('window.Gleap.startClassicForm')
external void startClassicForm(JSString formId);
