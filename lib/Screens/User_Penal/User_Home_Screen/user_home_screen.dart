import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserHomeScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  void markAttendance(BuildContext context) async {
    User? user = _auth.currentUser;
    String userId = user?.uid ?? '';

    if (userId.isNotEmpty) {
      String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      var attendanceDoc = await _firestore
          .collection('attendance')
          .doc(userId)
          .collection('dates')
          .doc(todayDate)
          .get();

      if (attendanceDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance already marked for today!')),
        );
      } else {
        await _firestore
            .collection('attendance')
            .doc(userId)
            .collection('dates')
            .doc(todayDate)
            .set({'status': 'Present', 'date': todayDate});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance marked successfully!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        title: const Text(
          'User Home',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => markAttendance(context),
              child: Text('Mark Attendance'),
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/view_attendance');
              },
              child: Text('View Attendance'),
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/edit_profile');
              },
              child: Text('Edit Profile Picture'),
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/send_leave_request');
              },
              child: Text('Send Leave Request'),
            ),
          ],
        ),
      ),
    );
  }
}
