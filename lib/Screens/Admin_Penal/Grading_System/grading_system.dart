// GradeCalculator.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GradeCalculator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> calculateGrade(String userId, DateTimeRange dateRange) async {
    Timestamp startTimestamp = Timestamp.fromDate(dateRange.start);
    Timestamp endTimestamp =
        Timestamp.fromDate(dateRange.end.add(Duration(days: 1)));

    QuerySnapshot querySnapshot = await _firestore
        .collection('attendance_records')
        .where('uid', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startTimestamp)
        .where('date', isLessThan: endTimestamp)
        .get();

    int totalDays = querySnapshot.docs.length;
    String grade;

    if (totalDays >= 26) {
      grade = 'A';
    } else if (totalDays >= 20) {
      grade = 'B';
    } else if (totalDays >= 15) {
      grade = 'C';
    } else if (totalDays >= 10) {
      grade = 'D';
    } else {
      grade = 'F';
    }

    return grade;
  }
}
