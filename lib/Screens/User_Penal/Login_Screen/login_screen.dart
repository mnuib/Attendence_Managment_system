import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserLoginScreen extends StatefulWidget {
  @override
  _UserLoginScreenState createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';

  void login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      Navigator.pushNamed(context, '/user_home');
    } catch (e) {
      print(e);
      // Handle login error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Login',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                onChanged: (value) => email = value,
                decoration: const InputDecoration(
                    hintText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
              ),
              TextField(
                onChanged: (value) => password = value,
                decoration: const InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock_open_outlined),
                    suffixIcon: Icon(Icons.remove_red_eye_outlined)),
                obscureText: true,
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: login,
                child: Text('Login'),
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('Don\'t have an account? Register'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/admin_login');
                },
                child: const Text('Admin Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
