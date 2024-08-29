import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewAttendanceScreen extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    String userId = user?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.green,
          centerTitle: true,
          title: const Text(
            'View Attendance',
            style: TextStyle(color: Colors.white),
          )),
      body: StreamBuilder(
        stream: _firestore
            .collection('attendance')
            .doc(userId)
            .collection('dates')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var attendanceRecords = snapshot.data?.docs;

          return ListView.builder(
            itemCount: attendanceRecords?.length ?? 0,
            itemBuilder: (context, index) {
              var record = attendanceRecords?[index];
              return ListTile(
                title: Text('Date: ${record?['date']}'),
                subtitle: Text('Status: ${record?['status']}'),
              );
            },
          );
        },
      ),
    );
  }
}
