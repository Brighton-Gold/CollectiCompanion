// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Function to create a new user
  Future<UserCredential?> createUser(String email, String password) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': email,
      });

      // Check if user is successfully created
      if (userCredential.user != null) {
        // Add user data to Firestore in the 'users' collection
        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .collection("itemList")
            .doc("Example")
            .set({
          'itemName': "name of item",
          'description': "description of item",
          'catalogId': 'Example'
        });

// Then, set the document in 'cataloglist' sub-collection
        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .collection("cataloglist")
            .doc("Example")
            .set({
          'catalogName': "Name of catalog",
          'description':
              "This is an example of what a catalog looks like, feel free to delete later!",
          'catalogId': 'Example'
        });

        return userCredential;
      } else {
        // Show error if user creation failed
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User creation failed')));
        return null;
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth exceptions
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The password provided is too weak.')));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The email address is already in use.')));
      }
      return null;
    } catch (e) {
      // Handle other exceptions
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to sign up: $e')));
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () async {
                UserCredential? userCredential = await createUser(
                    _emailController.text, _passwordController.text);
                if (userCredential != null) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) =>
                          HomePage(userId: userCredential.user!.uid),
                    ),
                  );
                }
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
