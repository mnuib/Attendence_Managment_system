import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageAttendanceScreen extends StatefulWidget {
  @override
  _ManageAttendanceScreenState createState() => _ManageAttendanceScreenState();
}

class _ManageAttendanceScreenState extends State<ManageAttendanceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch attendance records
  Future<List<DocumentSnapshot>> _getAttendanceRecords() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection('attendance_records').get();
    return querySnapshot.docs;
  }

  // Delete an attendance record
  void _deleteRecord(String id) async {
    await _firestore.collection('attendance_records').doc(id).delete();
    setState(() {});
  }

  // Edit an attendance record
  void _editRecord(String id, String currentStatus) async {
    TextEditingController _statusController =
        TextEditingController(text: currentStatus);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Attendance Record'),
          content: TextField(
            controller: _statusController,
            decoration: InputDecoration(labelText: 'Status'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Update the record with the new status
                await _firestore
                    .collection('attendance_records')
                    .doc(id)
                    .update({
                  'status': _statusController.text,
                });
                Navigator.of(context).pop();
                setState(() {});
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Attendance',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _getAttendanceRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No attendance records found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var record = snapshot.data![index];
              return ListTile(
                title: Text(
                  'User ID: ${record['uid']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                    'Date: ${record['date'].toDate()} - Status: ${record['status']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.green,
                        ),
                        onPressed: () =>
                            _editRecord(record.id, record['status'])),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () => _deleteRecord(record.id),
                    ),
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
