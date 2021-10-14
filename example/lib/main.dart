import 'package:flutter/material.dart';
import 'dart:async';

import 'package:gleap_sdk/gleap_sdk.dart';

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
    await Gleap.initialize(
      token: 'YOUR_API_KEY',
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
          child: GestureDetector(
            onTap: () async {
              await Gleap.startFeedbackFlow();
            },
            child: Container(
              alignment: Alignment.center,
              height: 50,
              width: 150,
              color: const Color(0xFF485BFF),
              child: const Text(
                'Report Bug',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
