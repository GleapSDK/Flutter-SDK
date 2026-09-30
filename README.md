# Gleap Flutter SDK

![Gleap Flutter SDK Intro](https://raw.githubusercontent.com/GleapSDK/Gleap-iOS-SDK/main/Resources/GleapHeaderImage.png)

Add AI-native customer support, live chat, in-app bug reporting, a help center and surveys to your Flutter apps with [Gleap](https://www.gleap.ai). Gleap is an Intercom alternative for software teams that connects customer conversations and feedback with product development.

[SDK documentation](https://docs.gleap.ai/documentation/flutter/README) · [Website](https://www.gleap.ai) · [Plans and pricing](https://www.gleap.ai/pricing)

## Docs & examples

Checkout our [documentation](https://docs.gleap.ai/documentation/flutter/README) for full reference. Include the following dependency in your pubspec.yaml:

```dart
dependencies:
  gleap_sdk: "^19.0.0"
```

**Flutter v2 support**

If you are using Flutter < v3, please import the gleap_sdk as shown below:

```dart
dependencies:
  gleap_sdk:
    git:
      url: https://github.com/GleapSDK/Flutter-SDK.git
      ref: flutter-v2

```

**Flutter v2 Support**
If you are using Flutter < v3, please import the gleap_sdk as shown below:

```dart
dependencies:
  gleap_sdk:
    git:
      url: git@github.com:GleapSDK/Flutter-SDK.git
      ref: flutter-v2

```

**Android installation**

Android should be already good to go. If theres a version conflict pls add the following to your android manifest:

```
<manifest ... xmlns:tools="http://schemas.android.com/tools">
 <uses-sdk  android:minSdkVersion="21"
        tools:overrideLibrary="io.gleap.gleap_sdk"/>
 <application .... tools:overrideLibrary="io.gleap.gleap_sdk">
 ...
 ```

Important: Always have a look at your minSdkVersion on android and your minimum target version on iOS to keep them on the same minimum version gleap needs.

**iOS installation**

Requirements: iOS 15.0 or newer, Flutter 3.41 or newer with Swift Package Manager enabled, Xcode 15 or newer.

Since 19.0.0 the iOS side of gleap_sdk is a Swift package: Flutter adds it and the native [Gleap iOS SDK](https://github.com/GleapSDK/Gleap-iOS-SDK) to your Xcode project automatically. There is no CocoaPods pod any more, because the CocoaPods registry becomes read-only on December 2, 2026.

- **Flutter 3.44 and newer:** Swift Package Manager is on by default. Just run `flutter run` / `flutter build ios`; the first run adds the Swift Package Manager integration to your Xcode project.
- **Flutter 3.41 to 3.43:** turn it on first, either for your machine with `flutter config --enable-swift-package-manager`, or for the project in your app's `pubspec.yaml`:

  ```yaml
  flutter:
    config:
      enable-swift-package-manager: true
  ```

Set your app's iOS deployment target (Runner → Minimum Deployments, and `platform :ios` in your Podfile if you still have one) to 15.0 or higher, otherwise Xcode reports that `gleap-sdk` requires iOS 15.0.

Upgrading from 18.x or older: remove any `pod 'Gleap'` line you added to your Podfile yourself (the Gleap iOS SDK now comes from the Swift package; having both links it twice). If gleap_sdk was your only plugin that needed CocoaPods, you can remove CocoaPods from your iOS project as described in [Swift Package Manager for app developers](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers#how-to-remove-cocoapods-integration); other plugins that still use CocoaPods keep working next to it.

Apps that embed Flutter into an existing iOS app (add-to-app) need the Swift Package Manager integration (`flutter build swift-package`, Flutter 3.44+) described in [Integrate a Flutter app into your iOS project](https://docs.flutter.dev/add-to-app/ios/project-setup); the CocoaPods and `flutter build ios-framework` integrations can't include gleap_sdk 19.

**Web installation**

Navigate to your web project folder and insert the following snippet as first element within the head tag of your index.html

```
<script>
!function(Gleap,t,i){if(!(Gleap=window.Gleap=window.Gleap||[]).invoked){for(window.GleapActions=[],Gleap.invoked=!0,Gleap.methods=["identify","updateContact","setEnvironment","setEnvDataPropsToIgnore","setDisableEnvData","setColorScheme","setTags","attachCustomData","setCustomData","removeCustomData","clearCustomData","setTicketAttribute","unsetTicketAttribute","clearTicketAttributes","registerCustomAction","registerAgentTool","trackEvent","log","preFillForm","showSurvey","sendSilentCrashReport","startFeedbackFlow","startClassicForm","startConversation","startBot","setAppBuildNumber","setAppVersionCode","setApiUrl","setFrameUrl","setRegion","setWSApiUrl","setRealtimeHost","setBannerUrl","setModalUrl","startNetworkLogger","setNetworkLogsBlacklist","setNetworkLogPropsToIgnore","setDisableInAppNotifications","isOpened","open","close","on","setLanguage","setOfflineMode","initialize","disableConsoleLogOverwrite","logEvent","hide","enableShortcuts","showFeedbackButton","destroy","getIdentity","isUserIdentified","clearIdentity","openConversations","openConversation","openChecklists","openChecklist","startChecklist","openHelpCenterCollection","openHelpCenterArticle", "askAI","openHelpCenter","searchHelpCenter","openNewsArticle","openNews","openFeatureRequests","isLiveMode"],Gleap.f=function(e){return function(){var t=Array.prototype.slice.call(arguments);window.GleapActions.push({e:e,a:t})}},t=0;t<Gleap.methods.length;t++)Gleap[i=Gleap.methods[t]]=Gleap.f(i);Gleap.load=function(){var t=document.getElementsByTagName("head")[0],i=document.createElement("script");i.type="text/javascript",i.async=!0,i.src="https://sdk.gleap.io/latest/index.js",t.appendChild(i)},Gleap.load()}}();
</script>
```

**Initialize Gleap SDK**

Import the Gleap SDK by adding the following import inside one of your root components.

```dart
import 'package:gleap_sdk/gleap_sdk.dart';
```

```dart
Gleap.initialize(token: 'YOUR_API_KEY')
```

Your API key can be found in the project settings within Gleap.

**Data regions**

Projects hosted in the US data region select it before initializing. The default region is `eu`, so existing integrations need no change.

```dart
await Gleap.setRegion(region: 'us');
await Gleap.initialize(token: 'YOUR_API_KEY');
```

`setRegion` sets the API, websocket and realtime hosts for the region at once; the static widget hosts are global and stay unchanged. For custom domains, the manual setters `setApiUrl`, `setWSApiUrl`, `setRealtimeHost`, `setFrameUrl`, `setBannerUrl` and `setModalUrl` are available. A manual setter called after `setRegion` overrides that single host.

On web, data regions require the loader snippet above (it queues the new methods until the JavaScript SDK has loaded).

**Dark mode**

Switch the widget between dark and light mode. `auto` follows the device appearance (on web: the page theme). If your app has its own theme toggle, pass `light` or `dark` explicitly and call it again whenever the theme changes:

```dart
await Gleap.setColorScheme(colorScheme: 'auto');
await Gleap.setColorScheme(
  colorScheme: Theme.of(context).brightness == Brightness.dark ? 'dark' : 'light',
  darkBackgroundColor: '#121212',
);
```

`setColorScheme` only takes effect when "Adapt to dark / light mode" is enabled in the Gleap dashboard; it then overrides the dashboard's color scheme. Before the first call the dashboard setting applies. In dark mode the widget uses the dark mode colors, logo, header image and composer glow set in the Gleap dashboard; without dark colors it keeps its normal colors. `lightBackgroundColor` / `darkBackgroundColor` override the background in light / dark mode. Can be called before or after `Gleap.initialize`.

**Network logging**

We support network logging for the packages [Http](https://pub.dev/packages/http) and [Dio](https://pub.dev/packages/dio). For details on how to enable network logging for these packages, check the [Gleap Http Interceptor](https://pub.dev/packages/gleap_http_interceptor) and the [Gleap Dio Interceptor](https://pub.dev/packages/gleap_dio_interceptor) packages (2.0 or newer).

Requests from any other client can be logged with `Gleap.logNetworkRequest`:

```dart
Gleap.logNetworkRequest(
  GleapNetworkLog(
    type: 'POST',
    url: 'https://api.example.com/orders',
    date: startedAt, // when the request started
    duration: stopwatch.elapsedMilliseconds.toDouble(),
    success: true, // false when no response arrived
    request: GleapNetworkRequest(
      headers: {'content-type': 'application/json'},
      payload: {'productId': 42}, // Maps and Lists are sent as JSON
    ),
    response: GleapNetworkResponse(
      status: 201,
      statusText: 'Created',
      headers: {'content-type': 'application/json'},
      responseText: responseBody,
      // for a failed request: GleapNetworkResponse(errorText: 'Connection refused')
    ),
  ),
);
```

Gleap keeps the newest 30 requests. `Gleap.setNetworkLogPropsToIgnore(propsToIgnore: ['password', 'token'])` removes headers, JSON keys (at any depth, `user.password` also works as a path), form fields and url query parameters with these names; `Gleap.setNetworkLogsBlacklist(blacklist: ['/internal/'])` skips requests whose url contains an entry. Authorization and cookie headers are always masked.

Switch network logging on or off from your app, also against the network logs setting in the Gleap dashboard:

```dart
await Gleap.stopNetworkLogging();
await Gleap.startNetworkLogging(); // resumes after a stop
```

Without these calls nothing changes: requests logged from Dart are attached, and the native recording on iOS and web follows the dashboard setting.

- **All platforms:** after `stopNetworkLogging`, `logNetworkRequest` and `attachNetworkLogs` (and with them the Gleap http and dio interceptors) ignore new requests until `startNetworkLogging` is called. Requests logged before stay attached.
- **iOS:** the native SDK records every NSURLSession request of the app (e.g. made by native plugins or `cupertino_http`) when network logs are enabled in the dashboard. `startNetworkLogging` starts this recording, `stopNetworkLogging` stops it.
- **Web:** `startNetworkLogging` also starts the JavaScript SDK's network logger (fetch and XMLHttpRequest). The JavaScript SDK can't stop it, so on web `stopNetworkLogging` only stops the requests logged from Dart.
