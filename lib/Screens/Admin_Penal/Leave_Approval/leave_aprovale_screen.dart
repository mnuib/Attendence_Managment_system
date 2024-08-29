import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewLeaveRequestsScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;

  void _approveLeave(String docId) async {
    await _firestore.collection('leave_requests').doc(docId).update({
      'status': 'Approved',
    });
  }

  void _rejectLeave(String docId) async {
    await _firestore.collection('leave_requests').doc(docId).update({
      'status': 'Rejected',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View Leave Requests',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('leave_requests').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          var requests = snapshot.data!.docs;
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index];
              return ListTile(
                title: Text(
                    'UID: ${request['uid']} - Reason: ${request['reason']} - Status: ${request['status']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: const Icon(
                          Icons.check,
                          color: Colors.green,
                        ),
                        onPressed: () => _approveLeave(request.id)),
                    IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                        onPressed: () => _rejectLeave(request.id)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
