import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'create_user.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signIn({required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> _signIn() async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // ignore: use_build_context_synchronously
      if (userCredential.user != null) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomePage(userId: userCredential.user!.uid),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // You can show an alert dialog or a snackbar here
      print("Error: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              "Welcome to CollectiCompanion",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _signIn,
              child: const Text("Login"),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to Forgot Password Screen
              },
              child: const Text("Forgot Password?"),
            ),
            TextButton(
              onPressed: () {
                // Navigate to Sign Up Screen
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SignUpScreen()));
              },
              child: const Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: camel_case_types
class createUser {
  const createUser();
}
