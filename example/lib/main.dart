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
    await Gleap.initialize(
      token: 'KProDXhMS0V3UUku2iNnrZ4XsBnAYzxt',
    );

    await Gleap.setLanguage(language: 'en');

    // Gleap.preFillForm(formData: <String, dynamic>{
    //   'bugdescription': 'While I was trying to do something, I found a bug.',
    // });

    Gleap.registerListener(
      actionName: 'custom-action',
      callbackHandler: (dynamic action) {
        print(action);
      },
    );
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
                  userHash:
                      "e12817b1f1xedb72381b249eb22ecd0dc1c4s0bb15188b5485d441485347y26f",
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
                await Gleap.trackPage(pageName: "WebWebWebWeb");
              },
              child: Container(
                alignment: Alignment.center,
                height: 50,
                width: 150,
                color: const Color(0xFF485BFF),
                child: const Text(
                  'Open news article',
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
                // Gleap.trackEvent(name: 'FIRST_EVENT');
                // Gleap.openNews();
                Navigator.of(context).pushNamed(SecondScreen.routeName);
                // Gleap.showFeedbackButton(true);
                // Gleap.openFeatureRequests();
                // bool isIdentified = await Gleap.isUserIdentified();
                // GleapUserProperty? userProperty = await Gleap.getIdentity();
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
