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

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if([@"initialize" isEqualToString:call.method]) {

    [Gleap initializeWithToken: call.arguments[@"token"]];

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
  else if([@"logEvent" isEqualToString: call.method]) {
    [Gleap logEvent: call.arguments[@"name"] withData: call.arguments[@"data"]];
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
  else {
    result(FlutterMethodNotImplemented);
  }
}

@end
