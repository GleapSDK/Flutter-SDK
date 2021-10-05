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
    GleapUserSession *userSession = [[GleapUserSession alloc] init];
    // userSession.userId = call.arguments[@"gleapUserSession"][@"userId"];
    // userSession.userHash = call.arguments[@"gleapUserSession"].userHash;
    // userSession.name = call.arguments[@"gleapUserSession"].name;
    // userSession.email = call.arguments[@"gleapUserSession"].email;

    [Gleap initializeWithToken: call.arguments[@"token"] andUserSession: userSession];
    [self initSDK];
  }
  else if([@"startFeedbackFlow" isEqualToString:call.method]) {
    [Gleap startFeedbackFlow];
  }
  else if([@"sendSilentBugReport" isEqualToString: call.method]) {
    if([call.arguments[@"severity"] isEqualToString: @"LOW"]){
      [Gleap sendSilentBugReportWith: call.arguments[@"description"] andPriority: LOW];
    } else if([call.arguments[@"severity"] isEqualToString: @"MEDIUM"]){
      [Gleap sendSilentBugReportWith: call.arguments[@"description"] andPriority: MEDIUM];
    } else if([call.arguments[@"severity"] isEqualToString: @"HIGH"]){
      [Gleap sendSilentBugReportWith: call.arguments[@"description"] andPriority: HIGH];
    } 
  }
  else if([@"identifyUserWith" isEqualToString: call.method]) {
    GleapUserSession *userSession = [[GleapUserSession alloc] init];
    // userSession.userId = call.arguments[@"gleapUserSession"].userId;
    // userSession.userHash = call.arguments[@"gleapUserSession"].userHash;
    // userSession.name = call.arguments[@"gleapUserSession"].name;
    // userSession.email = call.arguments[@"gleapUserSession"].email;

    [Gleap identifyUserWith: userSession];
  }
  else if([@"clearIdentity" isEqualToString: call.method]) {
    [Gleap clearIdentity];
  }
  else if([@"setApiUrl" isEqualToString: call.method]) {
    [Gleap setApiUrl: call.arguments[@"apiUrl"]];
  }
  else if([@"setWidgetUrl" isEqualToString: call.method]) {
    [Gleap setWidgetUrl: call.arguments[@"widgetUrl"]];
  }
  else if([@"setLanguage" isEqualToString: call.method]) {
    [Gleap setLanguage: call.arguments[@"language"]];
  }
  else if([@"attachCustomData" isEqualToString: call.method]) {
    [Gleap attachCustomData: call.arguments[@"customData"]];
  }
  else if([@"setCustomData" isEqualToString: call.method]) {
    [Gleap setCustomData: call.arguments[@"value"] forKey: call.arguments[@"key"]];
  }
  else if([@"removeCustomDataForKey" isEqualToString: call.method]) {
    [Gleap removeCustomDataForKey: call.arguments[@"key"]];
  }
  else if([@"clearCustomData" isEqualToString: call.method]) {
    [Gleap clearCustomData];
  }
  else if([@"startNetworkRecording" isEqualToString: call.method]) {
    [Gleap startNetworkRecording];
  }
  else if([@"startNetworkRecordingForSessionConfiguration" isEqualToString: call.method]) {
    [Gleap startNetworkRecordingForSessionConfiguration: call.arguments[@"configuration"]];
  }
  else if([@"stopNetworkRecording" isEqualToString: call.method]) {
    [Gleap stopNetworkRecording];
  }
  else if([@"logEvent" isEqualToString: call.method]) {
    [Gleap logEvent: call.arguments[@"name"] withData: call.arguments[@"data"]];
  }
  else {
    result(FlutterMethodNotImplemented);
  }
}

@end
