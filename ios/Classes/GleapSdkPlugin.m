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

- (void)bugWillBeSent {
  if (self.methodChannel != nil) {
    [self.methodChannel invokeMethod: @"setBugWillBeSentCallback" arguments: @{}];
  }
}

- (void)bugSent {
  if (self.methodChannel != nil) {
    [self.methodChannel invokeMethod: @"setBugSentCallback" arguments: @{}];
  }
}

- (void)bugSendingFailed {
  if (self.methodChannel != nil) {
    [self.methodChannel invokeMethod: @"setBugSendingFailedCallback" arguments: @{}];
  }
}

- (void)customActionCalled:(NSString *)customAction {
  if (self.methodChannel != nil) {
    [self.methodChannel invokeMethod: @"registerCustomAction" arguments: @{
      @"name": customAction
    }];
  }
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if([@"initialize" isEqualToString:call.method]) {
    if(call.arguments[@"gleapUserSession"] != nil) {
      GleapUserSession *userSession = [[GleapUserSession alloc] init];

      NSDictionary *sessionData = call.arguments[@"gleapUserSession"];
      userSession.userId = [sessionData objectForKey: @"userId"];
      userSession.userHash = [sessionData objectForKey: @"userHash"];
      userSession.name = [sessionData objectForKey: @"name"];
      userSession.email = [sessionData objectForKey: @"email"];

      [Gleap initializeWithToken: call.arguments[@"token"] andUserSession: userSession];
    } else {
      [Gleap initializeWithToken: call.arguments[@"token"]];
    }

    [self initSDK];
    result(nil);
  }
  else if([@"startFeedbackFlow" isEqualToString:call.method]) {
    [Gleap startFeedbackFlow];
    result(nil);
  }
  else if([@"sendSilentBugReport" isEqualToString: call.method]) {
    if([call.arguments[@"severity"] isEqualToString: @"LOW"]){
      [Gleap sendSilentBugReportWith: call.arguments[@"description"] andPriority: LOW];
    } else if([call.arguments[@"severity"] isEqualToString: @"MEDIUM"]){
      [Gleap sendSilentBugReportWith: call.arguments[@"description"] andPriority: MEDIUM];
    } else if([call.arguments[@"severity"] isEqualToString: @"HIGH"]){
      [Gleap sendSilentBugReportWith: call.arguments[@"description"] andPriority: HIGH];
    }
    result(nil);
  }
  else if([@"identifyUserWith" isEqualToString: call.method]) {
    GleapUserSession *userSession = [[GleapUserSession alloc] init];

    NSDictionary *sessionData = call.arguments[@"gleapUserSession"];
    userSession.userId = [sessionData objectForKey: @"userId"];
    userSession.userHash = [sessionData objectForKey: @"userHash"];
    userSession.name = [sessionData objectForKey: @"name"];
    userSession.email = [sessionData objectForKey: @"email"];

    [Gleap identifyUserWith: sessionData];
    result(nil);
  }
  else if([@"clearIdentity" isEqualToString: call.method]) {
    [Gleap clearIdentity];
    result(nil);
  }
  else if([@"setApiUrl" isEqualToString: call.method]) {
    [Gleap setApiUrl: call.arguments[@"apiUrl"]];
    result(nil);
  }
  else if([@"setWidgetUrl" isEqualToString: call.method]) {
    [Gleap setWidgetUrl: call.arguments[@"widgetUrl"]];
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
  else if([@"startNetworkRecording" isEqualToString: call.method]) {
    [Gleap startNetworkRecording];
    result(nil);
  }
  else if([@"startNetworkRecordingForSessionConfiguration" isEqualToString: call.method]) {
    [Gleap startNetworkRecordingForSessionConfiguration: call.arguments[@"configuration"]];
    result(nil);
  }
  else if([@"stopNetworkRecording" isEqualToString: call.method]) {
    [Gleap stopNetworkRecording];
    result(nil);
  }
  else if([@"logEvent" isEqualToString: call.method]) {
    [Gleap logEvent: call.arguments[@"name"] withData: call.arguments[@"data"]];
    result(nil);
  }
  else {
    result(FlutterMethodNotImplemented);
  }
}

@end
