import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MarkAttendanceScreen extends StatefulWidget {
  @override
  _MarkAttendanceScreenState createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool _isAttendanceMarked = false;

  @override
  void initState() {
    super.initState();
    _checkAttendance();
  }

  void _checkAttendance() async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(uid).get();
    List attendance = userDoc['attendance'];

    setState(() {
      _isAttendanceMarked = attendance.contains(today);
    });
  }

  void _markAttendance() async {
    if (_isAttendanceMarked) return;

    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String uid = _auth.currentUser!.uid;

    await _firestore.collection('users').doc(uid).update({
      'attendance': FieldValue.arrayUnion([today]),
      'presents': FieldValue.increment(1),
    });

    await _firestore.collection('attendance_records').add({
      'uid': uid,
      'date': today,
      'status': 'Present',
    });

    setState(() {
      _isAttendanceMarked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mark Attendance')),
      body: Center(
        child: _isAttendanceMarked
            ? Text('You have already marked attendance for today.')
            : ElevatedButton(
                onPressed: _markAttendance, child: Text('Mark Attendance')),
      ),
    );
  }
}
