import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    User? user = _auth.currentUser;
    String userId = user?.uid ?? '';

    if (_imageFile != null && userId.isNotEmpty) {
      try {
        // Create a reference to the Firebase Storage location
        Reference storageRef =
            _storage.ref().child('profile_pictures/$userId.jpg');

        // Upload the file
        await storageRef.putFile(_imageFile!);

        // Get the download URL
        String downloadURL = await storageRef.getDownloadURL();

        // Update the Firestore document with the new profile picture URL
        await _firestore.collection('users').doc(userId).update({
          'profile_picture': downloadURL,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile picture updated successfully!')),
        );
      } catch (e) {
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile picture')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected or user not logged in!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'Edit Profile Picture',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(70.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _imageFile == null
                  ? Text('No image selected.')
                  : Image.file(_imageFile!, height: 150, width: 150),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: _uploadImage,
                child: Text('Upload Profile Picture'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
