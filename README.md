# Gleap SDK

![Gleap Flutter SDK Intro](https://raw.githubusercontent.com/GleapSDK/Gleap-iOS-SDK/main/Resources/GleapHeaderImage.png)

The Gleap SDK for Flutter is the easiest way to integrate Gleap into your apps!

# Report and Fix Bugs the Easy Way

Gleap helps developers build the best software faster. It is your affordable in-app bug reporting tool for apps, websites and industrial applications.

Checkout our [website](https://gleap.io) to learn more about gleap.

## Docs & Examples

Checkout our [documentation](https://gleap.io/docs/flutter/) for full reference. Include the following dependency in your pubspec.yml:

```dart
dependencies:
  gleap_sdk: "^7.0.16"
```

**Flutter v2 Support**

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

Android is ready to go. If theres a version conflict pls add the following to your android manifest:

```
<manifest ... xmlns:tools="http://schemas.android.com/tools">
 <uses-sdk  android:minSdkVersion="21"
        tools:overrideLibrary="io.gleap.gleap_sdk"/>
 <application .... tools:overrideLibrary="io.gleap.gleap_sdk">
 ...
```

**iOS installation**

Navigate to your iOS project folder within the terminal and update the cocoapods by typing

```
pod install
```

**Web installation**

Navigate to your web project folder and insert the following snippet as first element within the head tag of your index.html

```
<script src="https://widget.gleap.io/widget/YOUR_API_KEY"></script>
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

**Network Logging**

We support network logging for the packages [Http](https://pub.dev/packages/http) and [Dio](https://pub.dev/packages/dio). For details on how to enable network logging for these packages, check the [Gleap Http Interceptor](https://pub.dev/packages/gleap_http_interceptor) and the [Gleap Dio Interceptor](https://pub.dev/packages/gleap_dio_interceptor) packages.
