#import <Flutter/Flutter.h>
// Under CocoaPods the Gleap pod is importable as <Gleap/Gleap.h>; under Swift
// Package Manager it is exposed as a clang module, so fall back to @import.
#if __has_include(<Gleap/Gleap.h>)
#import <Gleap/Gleap.h>
#else
@import Gleap;
#endif

@interface GleapSdkPlugin : NSObject<FlutterPlugin, GleapDelegate>
@end
