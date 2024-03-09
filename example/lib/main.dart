import 'package:flutter/material.dart';
import 'dart:async';
import 'package:gleap_sdk/gleap_sdk.dart';
import 'package:gleap_sdk/models/ai_tool_models/ai_tool_model/ai_tool_model.dart';
import 'package:gleap_sdk/models/ai_tool_models/ai_tool_params_model/ai_tool_params_model.dart';
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

    Gleap.registerListener(
      actionName: 'notificationCountUpdated',
      callbackHandler: (data) {
        print('Notification count updated: $data');
      },
    );

    Gleap.registerListener(
      actionName: 'toolExecution',
      callbackHandler: (data) {
        print('Tool execution: $data');
      },
    );

    await Gleap.initialize(
      token: '<YOUR_API_TOKEN>',
    );

    Gleap.setTags(tags: ['DevTag']);

    Gleap.showFeedbackButton(true);

    AITool transactionTool = AITool(
      name: 'send-money',
      description: 'Send money to a given contact.',
      response:
          'The transfer got initiated but not completed yet. The user must confirm the transfer in the banking app.',
      parameters: [
        AIToolParams(
          name: 'amount',
          description:
              'The amount of money to send. Must be positive and provided by the user.',
          type: AIParamType.NUMBER,
          required: true,
        ),
        AIToolParams(
          name: 'contact',
          description: 'The contact to send money to.',
          type: AIParamType.STRING,
          required: true,
          enums: ["Alice", "Bob"],
        ),
      ],
    );

    Gleap.setAiTools(tools: [transactionTool]);

    Gleap.setTicketAttribute(key: 'title', value: 'Developer title');
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
                    userId: "10293",
                    userProperties: GleapUserProperty(
                      email: "lukas@test.com",
                      companyId: "123",
                      name: "Lukas",
                      companyName: "test",
                      plan: "free",
                    ));
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
                Gleap.startConversation();
              },
              child: Container(
                alignment: Alignment.center,
                height: 50,
                width: 150,
                color: const Color(0xFF485BFF),
                child: const Text(
                  'Start conversation',
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
