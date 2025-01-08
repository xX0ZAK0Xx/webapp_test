import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'firebase_options.dart';
import 'src/launch_webview_new.dart';
import 'src/launch_webview_prev.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("8e00bb15-3ca4-4b50-8d9a-d5e5a0f479eb");
  OneSignal.Notifications.requestPermission(true);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const LaunchWebViewNew(
        title: "Tariqa Abululayia Siddiqia",
        launchUrl: "https://abululayia-siddiqia.org/securedsite/",
      ),
    ),
  );
}
