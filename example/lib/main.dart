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
      token: 'g4yw8blWFi0d50TubfV4iyN6HGG5Z2c1',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Gleap Example'),
          backgroundColor: const Color(0xFF485BFF),
        ),
        body: Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  await Gleap.identify(
                      userId: "1234",
                      userProperties: GleapUserProperty(
                          name: 'Franz', email: 'franz@gleap.io'),
                      userHash:
                          "e12817b1f1fedb72381b249eb22ece0dc1c470bb15188b5485d441485347926f");
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
                    'Clear identity',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  Gleap.registerCustomAction(
                      callbackHandler: (String actionName) {
                    // Do something with action
                    debugPrint('movieTitle: $actionName');
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 50,
                  width: 150,
                  color: const Color(0xFF485BFF),
                  child: const Text(
                    'Custom action',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
