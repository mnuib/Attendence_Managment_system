import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SystemWideReportScreen extends StatefulWidget {
  @override
  _SystemWideReportScreenState createState() => _SystemWideReportScreenState();
}

class _SystemWideReportScreenState extends State<SystemWideReportScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTimeRange? _dateRange;
  List<Map<String, dynamic>> _reports = [];
  bool _loading = false;

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
    if (_dateRange == null) return;

    setState(() {
      _loading = true; // Start loading
    });

    try {
      Timestamp startTimestamp = Timestamp.fromDate(_dateRange!.start);
      Timestamp endTimestamp = Timestamp.fromDate(
          _dateRange!.end.add(Duration(days: 1))); // Include the end day

      QuerySnapshot querySnapshot = await _firestore
          .collection('attendance_records')
          .where('date', isGreaterThanOrEqualTo: startTimestamp)
          .where('date', isLessThan: endTimestamp)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('No records found for the selected date range')),
        );
      }

      List<Map<String, dynamic>> reports = querySnapshot.docs.map((doc) {
        return {
          'uid': doc['uid'],
          'date': (doc['date'] as Timestamp).toDate(),
          'status': doc['status'],
        };
      }).toList();

      setState(() {
        _reports = reports;
        _loading = false; // End loading
      });
    } catch (e) {
      print('Error generating report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating report')),
      );
      setState(() {
        _loading = false; // End loading in case of error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'System-Wide Report',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(70.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _selectDateRange,
              child: Text('Select Date Range'),
            ),
            SizedBox(height: 15),
            _dateRange == null
                ? Text('No Date Range Selected')
                : Text(
                    '${DateFormat('yyyy-MM-dd').format(_dateRange!.start)} - ${DateFormat('yyyy-MM-dd').format(_dateRange!.end)}'),
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
                              title: Text('UID: ${report['uid']}'),
                              subtitle: Text(
                                  'Date: ${DateFormat('yyyy-MM-dd').format(report['date'])} - Status: ${report['status']}'),
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
