# Gleap SDK

The Gleap SDK for Flutter is the easiest way to integrate Gleap into your apps!

# Report and Fix Bugs the Easy Way
Gleap helps developers build the best software faster. It is your affordable in-app bug reporting tool for apps, websites and industrial applications.

Checkout our [website](https://gleap.io) to learn more about gleap.

## Docs & Examples

Checkout our [documentation](https://docs.gleap.io/docs/flutter-sdk) for full reference. Include the following dependency in your pubspec.yml:

```dart
dependencies:
  gleap_sdk: "^6.0.2"
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

**Initialize Gleap SDK**

Import the Gleap SDK by adding the following import inside one of your root components.

```dart
import 'package:gleap_sdk/gleap_sdk.dart';
```

```dart
Gleap.initialize(token: 'YOUR_API_KEY')
```

Your API key can be found in the project settings within Gleap.
