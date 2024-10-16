import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'splash_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAgxgEk7wpaxSjiQ2JOiriNVtDqQ8JYMtI",
          appId: "1:601880955368:android:0d1c768471533c4bca3c5d",
          messagingSenderId: "601880955368",
          projectId: "sky-analyzer"
      )
  );
  print("Firebase initialized");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}
