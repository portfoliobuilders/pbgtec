import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gtech/admin/dashboard.dart';
import 'package:gtech/firebase_options.dart';
import 'package:gtech/login.dart';
import 'package:gtech/splashscreen.dart';
import 'package:gtech/user/videosection.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    
      home: LoginPage(),
    );
  }
}

