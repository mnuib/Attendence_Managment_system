import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewAllUsersScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _getAllUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting all users: ${e.toString()}');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View All Users',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<Map<String, dynamic>> users = snapshot.data ?? [];

          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> user = users[index];
              return ListTile(
                title: Text(
                  user['name'] ?? 'No Name',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(user['email'] ?? 'No Email'),
                trailing: Text(
                  user['role'] ?? 'No Role',
                  style: const TextStyle(color: Colors.green, fontSize: 15),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
