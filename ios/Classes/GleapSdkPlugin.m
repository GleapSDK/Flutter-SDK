#import "GleapSdkPlugin.h"

@interface GleapSdkPlugin ()

@property (retain, nonatomic) FlutterMethodChannel *methodChannel;

@end

@implementation GleapSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"gleap_sdk"
            binaryMessenger:[registrar messenger]];
  GleapSdkPlugin* instance = [[GleapSdkPlugin alloc] init];
  instance.methodChannel = channel;
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)initSDK {
    Gleap.sharedInstance.delegate = self;
    [Gleap setApplicationType: FLUTTER];
}

- (void)feedbackFlowStarted:(NSDictionary *) feedbackAction {
  if (self.methodChannel != nil) {
    [self.methodChannel invokeMethod: @"feedbackFlowStarted" arguments: feedbackAction];
  }
}

- (void)feedbackSent:(NSDictionary *)data {
  if (self.methodChannel != nil) {
    [self.methodChannel invokeMethod: @"feedbackSent" arguments: data];
  }
}

- (void)initialized {
  if (self.methodChannel != nil) {
    [self.methodChannel invokeMethod: @"initialized" arguments: @{}];
  }
}

- (void)feedbackSendingFailed {
  if (self.methodChannel != nil) {
    [self.methodChannel invokeMethod: @"feedbackSendingFailed" arguments: @{}];
  }
}

- (void)customActionCalled:(NSString *)customAction {
  if (self.methodChannel != nil) {
    [self.methodChannel invokeMethod: @"customActionTriggered" arguments: @{
      @"name": customAction
    }];
  }
}

- (void)widgetOpened {
  if (self.methodChannel != nil) {
    [self.methodChannel invokeMethod: @"widgetOpened" arguments: @{}];
  }
}

- (void)widgetClosed {
  if (self.methodChannel != nil) {
    [self.methodChannel invokeMethod: @"widgetClosed" arguments: @{}];
  }
}

- (void) registerPushMessageGroup: (NSString *)pushMessageGroup {
  if (self.methodChannel != nil) {
    [self.methodChannel invokeMethod: @"registerPushMessageGroup" arguments: pushMessageGroup];
  }
}

- (void) unregisterPushMessageGroup: (NSString *)pushMessageGroup {
  if (self.methodChannel != nil) {
    [self.methodChannel invokeMethod: @"unregisterPushMessageGroup" arguments: pushMessageGroup];
  }
}

- (void)notificationCountUpdated:(NSInteger)count {
    if (self.methodChannel != nil) {
        [self.methodChannel invokeMethod:@"notificationCountUpdated" arguments:@(count)];
    }
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if([@"initialize" isEqualToString:call.method]) {

    [Gleap initializeWithToken: call.arguments[@"token"]];
    [Gleap trackEvent: @"pageView" withData: @{
      @"page": @"MainPage"
    }];

    [self initSDK];
    result(nil);
  }
  else if([@"startFeedbackFlow" isEqualToString:call.method]) {
    [Gleap startFeedbackFlow: call.arguments[@"action"] showBackButton: [call.arguments[@"showBackButton"] boolValue]];
    result(nil);
  }
  else if([@"sendSilentCrashReport" isEqualToString: call.method]) {
    GleapBugSeverity prio = MEDIUM;

    if([call.arguments[@"severity"] isEqualToString: @"LOW"]){
      prio = LOW;
    } else if([call.arguments[@"severity"] isEqualToString: @"MEDIUM"]){
      prio = MEDIUM;
    } else if([call.arguments[@"severity"] isEqualToString: @"HIGH"]){
      prio = HIGH;
    }
    
    [Gleap sendSilentCrashReportWith: call.arguments[@"description"] andSeverity: prio andDataExclusion: call.arguments[@"excludeData"] andCompletion:^(bool success) {}];

    result(nil);
  }
  else if([@"identify" isEqualToString: call.method]) {
    GleapUserProperty *userProperty = [[GleapUserProperty alloc] init];
    NSDictionary *propertyData = call.arguments[@"userProperties"];
    if ([propertyData objectForKey: @"name"] != nil) {
        userProperty.name = [propertyData objectForKey: @"name"];
    }
    if ([propertyData objectForKey: @"email"] != nil) {
        userProperty.email = [propertyData objectForKey: @"email"];
    }
    if ([propertyData objectForKey: @"phone"] != nil) {
        userProperty.phone = [propertyData objectForKey: @"phone"];
    }
    if ([propertyData objectForKey: @"plan"] != nil) {
        userProperty.plan = [propertyData objectForKey: @"plan"];
    }
    if ([propertyData objectForKey: @"companyName"] != nil) {
        userProperty.companyName = [propertyData objectForKey: @"companyName"];
    }
    if ([propertyData objectForKey: @"companyId"] != nil) {
        userProperty.companyId = [propertyData objectForKey: @"companyId"];
    }
    if ([propertyData objectForKey: @"value"] != nil) {
        userProperty.value = [propertyData objectForKey: @"value"];
    }
    if ([propertyData objectForKey: @"customData"] != nil) {
        userProperty.customData = [propertyData objectForKey: @"customData"];
    }

    [Gleap identifyUserWith: call.arguments[@"userId"] andData: userProperty andUserHash: call.arguments[@"userHash"]];
    result(nil);
  }
  else if([@"clearIdentity" isEqualToString: call.method]) {
    [Gleap clearIdentity];
    result(nil);
  }
  else if([@"setLanguage" isEqualToString: call.method]) {
    [Gleap setLanguage: call.arguments[@"language"]];
    result(nil);
  }
  else if([@"attachCustomData" isEqualToString: call.method]) {
    [Gleap attachCustomData: call.arguments[@"customData"]];
    result(nil);
  }
  else if([@"preFillForm" isEqualToString: call.method]) {
    [Gleap preFillForm: call.arguments[@"formData"]];
    result(nil);
  }
  else if([@"setCustomData" isEqualToString: call.method]) {
    [Gleap setCustomData: call.arguments[@"value"] forKey: call.arguments[@"key"]];
    result(nil);
  }
  else if([@"removeCustomDataForKey" isEqualToString: call.method]) {
    [Gleap removeCustomDataForKey: call.arguments[@"key"]];
    result(nil);
  }
  else if([@"clearCustomData" isEqualToString: call.method]) {
    [Gleap clearCustomData];
    result(nil);
  }
  else if([@"trackEvent" isEqualToString: call.method]) {
    [Gleap trackEvent: call.arguments[@"name"] withData: call.arguments[@"data"]];
    result(nil);
  }
  else if([@"trackPage" isEqualToString: call.method]) {
    [Gleap trackEvent: @"pageView" withData: @{
      @"page": call.arguments[@"pageName"]
    }];
    result(nil);
  }
  else if([@"setActivationMethods" isEqualToString: call.method]) {
    NSArray *activationMethods = call.arguments[@"activationMethods"];
    NSMutableArray *internalActivationMethods = [[NSMutableArray alloc] init];
    for (int i = 0; i < activationMethods.count; i++) {
        if ([[activationMethods objectAtIndex: i] isEqualToString: @"SHAKE"]) {
            [internalActivationMethods addObject: @(SHAKE)];
        }
        if ([[activationMethods objectAtIndex: i] isEqualToString: @"SCREENSHOT"]) {
            [internalActivationMethods addObject: @(SCREENSHOT)];
        }
    }
    
    [Gleap setActivationMethods: internalActivationMethods];
    result(nil);
  }
  else if([@"addAttachment" isEqualToString: call.method]) {
    NSData *fileData = [[NSData alloc] initWithBase64EncodedString: call.arguments[@"base64file"] options:0];
    if (fileData != nil) {
        [Gleap addAttachmentWithData: fileData andName: call.arguments[@"fileName"]];
        result(nil);

    } else {
        result(nil);
    }
  }
  else if([@"attachNetworkLogs" isEqualToString: call.method]) {
     [Gleap attachExternalData: @{ @"networkLogs": call.arguments[@"networkLogs"] }];
  }
  else if([@"removeAllAttachments" isEqualToString: call.method]) {
    [Gleap removeAllAttachments];
    result(nil);
  }
  else if([@"enableDebugConsoleLog" isEqualToString: call.method]) {
    [Gleap enableDebugConsoleLog];
    result(nil);
  }
  else if([@"openWidget" isEqualToString: call.method]) {
    [Gleap open];
    result(nil);
  }
  else if([@"closeWidget" isEqualToString: call.method]) {
    [Gleap close];
    result(nil);
  }
  else if([@"setApiUrl" isEqualToString: call.method]) {
    [Gleap setApiUrl: call.arguments[@"url"]];
    result(nil);
  }
  else if([@"setFrameUrl" isEqualToString: call.method]) {
    [Gleap setFrameUrl: call.arguments[@"url"]];
    result(nil);
  }
  else if([@"isOpened" isEqualToString: call.method]) {
    BOOL isOpened = [Gleap isOpened];
    result(@(isOpened));
  }
  else if([@"log" isEqualToString: call.method]) {
    GleapLogLevel logLevel = INFO;

    if([call.arguments[@"logLevel"] isEqualToString: @"INFO"]){
      logLevel = INFO;
    } else if([call.arguments[@"logLevel"] isEqualToString: @"WARNING"]){
      logLevel = WARNING;
    } else if([call.arguments[@"logLevel"] isEqualToString: @"ERROR"]){
      logLevel = ERROR;
    }

    [Gleap log: call.arguments[@"message"] withLogLevel: logLevel];
    result(nil);
  }
  else if([@"disableConsoleLog" isEqualToString: call.method]) {
    [Gleap disableConsoleLog];
    result(nil);
  }
  else if([@"showFeedbackButton" isEqualToString: call.method]) {
    [Gleap showFeedbackButton: [call.arguments[@"visible"] boolValue]];
    result(nil);
  }
  else if([@"openChecklists" isEqualToString: call.method]) {
    @try {
      [Gleap openChecklists: [call.arguments[@"showBackButton"] boolValue]];
    } @catch (NSException *exception) {
      [Gleap openChecklists];
    }
    result(nil);    
  }
  else if([@"openChecklist" isEqualToString: call.method]) {
    [Gleap openChecklist: call.arguments[@"checklistId"] andShowBackButton: [call.arguments[@"showBackButton"] boolValue]];
    result(nil);
  }
  else if([@"startChecklist" isEqualToString: call.method]) {
    [Gleap startChecklist: call.arguments[@"outboundId"] andShowBackButton: [call.arguments[@"showBackButton"] boolValue]];
    result(nil);
  }
  else if([@"openNews" isEqualToString: call.method]) {
    @try {
      [Gleap openNews: [call.arguments[@"showBackButton"] boolValue]];
    } @catch (NSException *exception) {
      [Gleap openNews];
    }
    result(nil);    
  }
  else if([@"openNewsArticle" isEqualToString: call.method]) {
    [Gleap openNewsArticle: call.arguments[@"articleId"] andShowBackButton: [call.arguments[@"showBackButton"] boolValue]];
    result(nil);
  }
  else if([@"openFeatureRequests" isEqualToString: call.method]) {
    @try {
      [Gleap openFeatureRequests: [call.arguments[@"showBackButton"] boolValue]];
    } @catch (NSException *exception) {
      [Gleap openFeatureRequests];
    }
    result(nil);
  }
  else if([@"openHelpCenter" isEqualToString: call.method]) {
    [Gleap openHelpCenter: [call.arguments[@"showBackButton"] boolValue]];
    result(nil);
  }
  else if([@"openHelpCenterArticle" isEqualToString: call.method]) {
    @try {
      [Gleap openHelpCenterArticle: call.arguments[@"articleId"] andShowBackButton: [call.arguments[@"showBackButton"] boolValue]];
    }
    @catch (NSException *exception) {
      
    }
    result(nil);
  }
  else if([@"openHelpCenterCollection" isEqualToString: call.method]) {
    @try {
      [Gleap openHelpCenterCollection: call.arguments[@"collectionId"] andShowBackButton: [call.arguments[@"showBackButton"] boolValue]];
    }
    @catch (NSException *exception) {
      
    }
    result(nil);
  }
  else if([@"searchHelpCenter" isEqualToString: call.method]) {
    @try {
      [Gleap searchHelpCenter: call.arguments[@"term"] andShowBackButton: [call.arguments[@"showBackButton"] boolValue]];
    }
    @catch (NSException *exception) {
      
    }
    result(nil);
  }
  else if([@"isUserIdentified" isEqualToString: call.method]) {
    BOOL isIdentified = [Gleap isUserIdentified];
    result(@(isIdentified));
  }
  else if([@"getIdentity" isEqualToString: call.method]) {
    NSDictionary * userIdentity = [Gleap getIdentity];
    result(userIdentity);
  }
  else if([@"showSurvey" isEqualToString: call.method]) {
    GleapSurveyFormat surveyFormat = SURVEY;
    if (call.arguments[@"format"] != nil && [call.arguments[@"format"] isEqualToString: @"survey_full"]) {
      surveyFormat = SURVEY_FULL;
    }

    [Gleap showSurvey: call.arguments[@"surveyId"] andFormat: surveyFormat];
    result(nil);
  }
  else if([@"setTags" isEqualToString: call.method]) {
    [Gleap setTags: call.arguments[@"tags"]];
    result(nil);
  }
  else if([@"setDisableInAppNotifications" isEqualToString: call.method]) {
    [Gleap setDisableInAppNotifications: [call.arguments[@"disable"] boolValue]];
    result(nil);
  }
  else if([@"openConversation" isEqualToString: call.method]) {
    [Gleap openConversation: call.arguments[@"shareToken"]];
    result(nil);
  }
  else if([@"handlePushNotification" isEqualToString: call.method]) {
    [Gleap handlePushNotification: call.arguments[@"data"]];
  }
  else if([@"startBot" isEqualToString: call.method]) {
    [Gleap startBot: call.arguments[@"botId"] showBackButton: [call.arguments[@"showBackButton"] boolValue]];
  }
  else if([@"startClassicForm" isEqualToString: call.method]) {
    [Gleap startClassicForm: call.arguments[@"formId"] showBackButton: [call.arguments[@"showBackButton"] boolValue]];
  }
  else if([@"startConversation" isEqualToString: call.method]) {
    [Gleap startConversation: [call.arguments[@"showBackButton"] boolValue]];
  }
  else {
    result(FlutterMethodNotImplemented);
  }
}

@end
