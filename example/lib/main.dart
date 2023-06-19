import 'package:flutter/material.dart';
import 'dart:async';
import 'package:gleap_sdk/gleap_sdk.dart';
import 'package:gleap_sdk/models/gleap_user_property_model/gleap_user_property_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    await Gleap.enableDebugConsoleLog();
    Gleap.setLanguage(language: 'en');

    Gleap.registerPushMessageGroup(callbackHandler: (String topic) {
      print('Subscribe to Topic: $topic');
    });

    Gleap.unregisterPushMessageGroup(callbackHandler: (String topic) {
      print('Unsubscribe from Topic: $topic');
    });

    await Gleap.initialize(
      token: '<YOUR_API_TOKEN>',
    );

    Gleap.setTags(tags: ['DevTag']);

    Gleap.showFeedbackButton(true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainScreen(),
      routes: {
        MainScreen.routeName: (context) => const MainScreen(),
        SecondScreen.routeName: (context) => const SecondScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  static String routeName = '/main-screen';
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gleap Example'),
        backgroundColor: const Color(0xFF485BFF),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                await Gleap.identify(
                  userId: "123456",
                  userProperties: GleapUserProperty(
                    name: 'Franz',
                    email: 'franz@gleap.io',
                    customData: <String, dynamic>{
                      'abc': 'Test Web',
                      'env': 'Flutter Web',
                      'party': true,
                    },
                  ),
                );
              },
              child: Container(
                alignment: Alignment.center,
                height: 50,
                width: 150,
                color: const Color(0xFF485BFF),
                child: const Text(
                  'Identify',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            GestureDetector(
              onTap: () async {
                await Gleap.clearIdentity();
              },
              child: Container(
                alignment: Alignment.center,
                height: 50,
                width: 150,
                color: const Color(0xFF485BFF),
                child: const Text(
                  'Clear identifity',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            GestureDetector(
              onTap: () async {
                await Gleap.openHelpCenterCollection(
                    collectionId: "1", showBackButton: false);
              },
              child: Container(
                alignment: Alignment.center,
                height: 50,
                width: 150,
                color: const Color(0xFF485BFF),
                child: const Text(
                  'Open help center',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            GestureDetector(
              onTap: () async {
                Navigator.of(context).pushNamed(SecondScreen.routeName);
              },
              child: Container(
                alignment: Alignment.center,
                height: 50,
                width: 150,
                color: const Color(0xFF485BFF),
                child: const Text(
                  'Navigate',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Container(
              height: 60.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  static String routeName = '/second-screen';
  const SecondScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text('Second screen'),
    );
  }
}
