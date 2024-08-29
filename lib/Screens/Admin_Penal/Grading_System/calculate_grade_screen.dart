import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'grading_system.dart'; // Import the GradeCalculator class

class CalculateGradeScreen extends StatefulWidget {
  @override
  _CalculateGradeScreenState createState() => _CalculateGradeScreenState();
}

class _CalculateGradeScreenState extends State<CalculateGradeScreen> {
  final GradeCalculator _gradeCalculator = GradeCalculator();
  String?
      _selectedUserId; // Make it nullable to handle cases where no user is selected
  DateTimeRange? _dateRange;
  String? _calculatedGrade;

  Future<List<DocumentSnapshot>> _getUsers() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    return querySnapshot.docs;
  }

  Future<void> _calculateGrade() async {
    if (_selectedUserId == null || _dateRange == null) return;
    String grade =
        await _gradeCalculator.calculateGrade(_selectedUserId!, _dateRange!);
    setState(() {
      _calculatedGrade = grade;
    });
  }

  void _selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calculate User Grades',
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
                if (!snapshot.hasData) return CircularProgressIndicator();
                if (snapshot.hasError) return Text('Error loading users');

                // Ensure that selected user ID exists in the dropdown list
                List<DropdownMenuItem<String>> userItems = snapshot.data!
                    .map((doc) => DropdownMenuItem(
                          value: doc.id,
                          child: Text(doc['email']),
                        ))
                    .toList();

                // Handle the case where _selectedUserId is not in the list
                if (_selectedUserId != null &&
                    !userItems.any((item) => item.value == _selectedUserId)) {
                  _selectedUserId = null;
                }

                return DropdownButton<String>(
                  hint: Text('Select User'),
                  value: _selectedUserId,
                  items: userItems,
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
            if (_dateRange != null)
              Text(
                'Selected Date Range: ${DateFormat('yyyy-MM-dd').format(_dateRange!.start)} - ${DateFormat('yyyy-MM-dd').format(_dateRange!.end)}',
              ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              onPressed: _calculateGrade,
              child: Text('Calculate Grade'),
            ),
            const SizedBox(
              height: 15,
            ),
            if (_calculatedGrade != null)
              Text('Grade: $_calculatedGrade', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
