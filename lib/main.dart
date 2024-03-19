import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login.dart'; // Import Login Screen
import 'home.dart'; // Import Home Screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey:
          "AIzaSyBCwCnZfJsBlBbqee04V66_AoboLrEnXKA", // Replace with actual keys
      authDomain: "collecticompanion.firebaseapp.com",
      projectId: "collecticompanion",
      storageBucket: "collecticompanion.appspot.com",
      messagingSenderId: "987253529390",
      appId: "1:987253529390:web:63ef90dd35c929b956f8bf",
    ),
  );
  runApp(const MyApp());
}

Widget initialScreen() {
  return StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.active) {
        // Check if the snapshot has any data (user is logged in)
        User? user = snapshot.data;
        if (user == null) {
          return const LoginScreen(); // User not logged in, show login screen
        }
        return HomePage(
            userId: user.uid); // User is logged in, show home screen
      }
      // Waiting for connection state to be active (add a loading indicator)
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: initialScreen(),
    );
  }
}
