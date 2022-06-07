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
      token: '3uljsPCtwxrXsROjnETeY26WW2HOQYEs',
    );

    // Gleap.preFillForm(formData: <String, dynamic>{
    //   'bugdescription': 'blablalballaa',
    // });

    Gleap.registerListener(
      actionName: 'widgetOpened',
      callbackHandler: (dynamic action) {
        print("widgetOpened");
        print(action);
      },
    );

    Gleap.registerListener(
      actionName: 'widgetClosed',
      callbackHandler: (dynamic action) {
        print("widgetClosed");
        print(action);
      },
    );

    Gleap.registerListener(
      actionName: 'feedbackSent',
      callbackHandler: (dynamic action) {
        print("feedbackSent");
        print(action);
      },
    );

    Gleap.registerListener(
      actionName: 'feedbackFlowStarted',
      callbackHandler: (dynamic action) {
        print("feedbackFlowStarted");
        print(action);
      },
    );

    Gleap.registerListener(
      actionName: 'custom-action',
      callbackHandler: (dynamic action) {
        print("custom-action");
        print(action);
      },
    );

    Gleap.attachCustomData(customData: <String, dynamic>{
      'customdata': 'blablalballaa',
    });

    Gleap.setCustomData(key: 'key', value: 'value');
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
                    userId: "123456",
                    userProperties: GleapUserProperty(
                      name: 'Franz von Gleap',
                      email: 'franz@gleap.io',
                    ),
                    userHash:
                        "e12817b1f1fedb72381b249eb22ece0dc1c470bb15188b5485d441485347926f",
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
                  // Gleap.registerCustomAction(
                  //     callbackHandler: (String actionName) {
                  //   // Do something with action
                  //   debugPrint('movieTitle: $actionName');
                  // });
                  // Gleap.sendSilentCrashReport(
                  //   description: 'android silent crash report',
                  //   severity: Severity.HIGH,
                  // );

                  // Gleap.startFeedbackFlow(
                  //   feedbackAction: 'bugreporting',
                  //   showBackButton: false,
                  // );

                  Gleap.open();

                  Future.delayed(Duration(seconds: 5), () async {
                    bool isOpened = await Gleap.isOpened();

                    print("isOpened");
                    print(isOpened);

                    print("xlose widget");

                    Gleap.close();
                  });

                  // print("finisheddd");
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
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a search term',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
