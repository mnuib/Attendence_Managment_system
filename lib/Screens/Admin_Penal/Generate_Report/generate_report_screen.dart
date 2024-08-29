import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserSpecificReportScreen extends StatefulWidget {
  @override
  _UserSpecificReportScreenState createState() =>
      _UserSpecificReportScreenState();
}

class _UserSpecificReportScreenState extends State<UserSpecificReportScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedUserId;
  DateTimeRange? _dateRange;
  List<Map<String, dynamic>> _reports = [];
  bool _loading = false;

  Future<List<DocumentSnapshot>> _getUsers() async {
    QuerySnapshot querySnapshot = await _firestore.collection('users').get();
    return querySnapshot.docs;
  }

  void _selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  Future<void> _generateReport() async {
    if (_selectedUserId == null || _dateRange == null) return;

    setState(() {
      _loading = true;
    });

    try {
      Timestamp startTimestamp = Timestamp.fromDate(_dateRange!.start);
      Timestamp endTimestamp =
          Timestamp.fromDate(_dateRange!.end.add(Duration(days: 1)));

      QuerySnapshot querySnapshot = await _firestore
          .collection('attendance_records')
          .where('uid', isEqualTo: _selectedUserId)
          .where('date', isGreaterThanOrEqualTo: startTimestamp)
          .where('date', isLessThan: endTimestamp)
          .get();

      List<Map<String, dynamic>> reports = querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {
          'name': data.containsKey('name') ? data['name'] : 'Unknown',
          'date': (data['date'] as Timestamp).toDate(),
          'status': data['status'],
        };
      }).toList();

      setState(() {
        _reports = reports;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating report: $e')),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _saveAttendanceRecord(
      String userId, DateTime date, String status) async {
    try {
      // Fetch user data to get the name
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('User does not exist');
      }
      var userData = userDoc.data() as Map<String, dynamic>;
      String userName =
          userData.containsKey('name') ? userData['name'] : 'Unknown';

      // Save the attendance record with the name
      await _firestore.collection('attendance_records').add({
        'uid': userId,
        'name': userName,
        'date': Timestamp.fromDate(date),
        'status': status,
      });
      print('Attendance record saved successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance record saved successfully')),
      );
    } catch (e) {
      print('Error saving attendance record: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving attendance record: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User-Specific Report',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<List<DocumentSnapshot>>(
              future: _getUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                if (snapshot.hasError) return const Text('Error loading users');

                return DropdownButton<String>(
                  hint: const Text('Select User'),
                  value: _selectedUserId,
                  items: snapshot.data!.map((doc) {
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(doc['email']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUserId = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              onPressed: _selectDateRange,
              child: Text('Select Date Range'),
            ),
            const SizedBox(
              height: 15,
            ),
            _dateRange == null
                ? Text('No Date Range Selected')
                : Text(
                    '${DateFormat('yyyy-MM-dd').format(_dateRange!.start)} - ${DateFormat('yyyy-MM-dd').format(_dateRange!.end)}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_selectedUserId != null && _dateRange != null) {
                  // Example data to save
                  await _saveAttendanceRecord(
                      _selectedUserId!, DateTime.now(), 'Present');
                }
              },
              child: const Text('Save Attendance Record'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateReport,
              child: Text('Generate Report'),
            ),
            SizedBox(height: 20),
            _loading
                ? Center(child: CircularProgressIndicator())
                : _reports.isEmpty
                    ? Text('No records found')
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _reports.length,
                          itemBuilder: (context, index) {
                            final report = _reports[index];
                            return ListTile(
                              title: Text(
                                report['name'] ?? 'Unknown',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                DateFormat('yyyy-MM-dd').format(report['date']),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              trailing: Text(
                                report['status'],
                                style: TextStyle(
                                  color: report['status'] == 'Present'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
