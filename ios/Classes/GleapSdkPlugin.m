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

- (void)feedbackWillBeSent {
  if (self.methodChannel != nil) {
    [self.methodChannel invokeMethod: @"feedbackWillBeSentCallback" arguments: @{}];
  }
}

- (void)feedbackSent {
  if (self.methodChannel != nil) {
    [self.methodChannel invokeMethod: @"feedbackSentCallback" arguments: @{}];
  }
}

- (void)feedbackSendingFailed {
  if (self.methodChannel != nil) {
    [self.methodChannel invokeMethod: @"feedbackSendingFailedCallback" arguments: @{}];
  }
}

- (void)customActionCalled:(NSString *)customAction {
  if (self.methodChannel != nil) {
    [self.methodChannel invokeMethod: @"customActionCallback" arguments: @{
      @"name": customAction
    }];
  }
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if([@"initialize" isEqualToString:call.method]) {

    [Gleap initializeWithToken: call.arguments[@"token"]];

    [self initSDK];
    result(nil);
  }
  else if([@"startFeedbackFlow" isEqualToString:call.method]) {
    [Gleap startFeedbackFlow: call.arguments[@"action"]];
    result(nil);
  }
  else if([@"sendSilentBugReport" isEqualToString: call.method]) {
    if([call.arguments[@"severity"] isEqualToString: @"LOW"]){
      [Gleap sendSilentBugReportWith: call.arguments[@"description"] andSeverity: LOW];
    } else if([call.arguments[@"severity"] isEqualToString: @"MEDIUM"]){
      [Gleap sendSilentBugReportWith: call.arguments[@"description"] andSeverity: MEDIUM];
    } else if([call.arguments[@"severity"] isEqualToString: @"HIGH"]){
      [Gleap sendSilentBugReportWith: call.arguments[@"description"] andSeverity: HIGH];
    }
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

    [Gleap identifyUserWith: call.arguments[@"userId"] andData: userProperty];
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
  // else if([@"startNetworkLogging" isEqualToString: call.method]) {
  //   [Gleap startNetworkLogging];
  //   result(nil);
  // }
  // else if([@"stopNetworkLogging" isEqualToString: call.method]) {
  //   [Gleap stopNetworkLogging];
  //   result(nil);
  // }
  else if([@"logEvent" isEqualToString: call.method]) {
    [Gleap logEvent: call.arguments[@"name"] withData: call.arguments[@"data"]];
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
  else {
    result(FlutterMethodNotImplemented);
  }
}

@end
