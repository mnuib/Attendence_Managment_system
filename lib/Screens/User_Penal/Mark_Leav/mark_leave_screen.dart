import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SendLeaveRequestScreen extends StatefulWidget {
  @override
  _SendLeaveRequestScreenState createState() => _SendLeaveRequestScreenState();
}

class _SendLeaveRequestScreenState extends State<SendLeaveRequestScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String leaveReason = '';

  void _sendLeaveRequest() async {
    String uid = _auth.currentUser!.uid;
    try {
      await _firestore.collection('leave_requests').add({
        'uid': uid,
        'reason': leaveReason,
        'status': 'Pending',
        'date': DateTime.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Leave request sent successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending leave request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Send Leave Request',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => leaveReason = value,
              decoration: const InputDecoration(
                hintText: 'Reason',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendLeaveRequest,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
