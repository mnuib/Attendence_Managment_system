import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRegistrationScreen extends StatefulWidget {
  @override
  _UserRegistrationScreenState createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String email = '';
  String password = '';
  String name = '';
  String role = 'user'; // Default role
  bool isFirstAdmin =
      false; // Flag to track if the first admin is being registered

  // Check if an admin already exists
  Future<void> _checkAdminExists() async {
    QuerySnapshot adminQuery = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .get();

    if (adminQuery.docs.isEmpty) {
      // No admin exists, set role to admin for the first user
      setState(() {
        role = 'admin';
        isFirstAdmin = true;
      });
    } else {
      setState(() {
        role = 'user';
        isFirstAdmin = false;
      });
    }
  }

  void register() async {
    try {
      await _checkAdminExists(); // Check if an admin exists before registration

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save user details in Firestore, including name and role
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'name': name,
        'role': role,
      });

      Navigator.pushNamed(context,
          '/user_login'); // Navigate to login screen after successful registration

      if (isFirstAdmin) {
        // Show a message to the user that they are the first admin
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have been registered as the Admin.')),
        );
      } else {
        // Show a message to the user that they are registered as a user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have been registered as a User.')),
        );
      }
    } catch (e) {
      print(e);
      // Handle registration error, show a message, etc.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'User Registration',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                onChanged: (value) => name = value,
                decoration: const InputDecoration(
                    hintText: 'Name', prefixIcon: Icon(Icons.person_outline)),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) => email = value,
                decoration: const InputDecoration(
                    hintText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) => password = value,
                decoration: const InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock_open),
                    suffixIcon: Icon(Icons.remove_red_eye)),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              // Display the role the user is being registered as
              Text(
                isFirstAdmin
                    ? 'You are registering as the Admin.'
                    : 'You are registering as a User.',
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: register,
                child: const Text('Register'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                      context, '/user_login'); // Navigate to login screen
                },
                child: const Text(
                  'Already have an account? Click here to login',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
