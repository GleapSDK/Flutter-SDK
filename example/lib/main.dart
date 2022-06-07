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
      token: 'API_KEY',
    );

    Gleap.preFillForm(formData: <String, dynamic>{
      'bugdescription': 'While I was trying to do something, I found a bug.',
    });

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
      home: Scaffold(
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
              const SizedBox(
                height: 20.0,
              ),
              GestureDetector(
                onTap: () async {
                  Gleap.sendSilentCrashReport(
                    description: 'Silent crash report',
                    severity: Severity.HIGH,
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 50,
                  width: 150,
                  color: const Color(0xFF485BFF),
                  child: const Text(
                    'Silent crash report',
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
