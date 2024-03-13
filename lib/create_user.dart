import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class SignUpScreen extends StatefulWidget {
  @override
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
          'Name': "name of item",
          'Description': "description of item",
        });

// Then, set the document in 'cataloglist' sub-collection
        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .collection("cataloglist")
            .doc("Example")
            .set({
          'catalogName': "books",
        });

        return userCredential;
      } else {
        // Show error if user creation failed
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('User creation failed')));
        return null;
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth exceptions
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('The password provided is too weak.')));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('The email address is already in use.')));
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
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () async {
                UserCredential? userCredential = await createUser(
                    _emailController.text, _passwordController.text);
                if (userCredential != null) {
                  // Navigate to the home screen on successful signup
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomePage()));
                }
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
