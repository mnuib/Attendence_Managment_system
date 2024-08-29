import 'package:flutter/material.dart';
import '../Generate_Report/generate_report_screen.dart';
import '../Leave_Approval/leave_aprovale_screen.dart';
import '../Manage_Attendence_Scree/manage_Attendece_screen.dart';
import '../View_All_User/view_all_user_screen.dart';
import 'package:attendence_managment_system/Screens/Admin_Penal/Generate_Report/system_wide_report.dart';

import 'package:attendence_managment_system/Screens/Admin_Penal/Grading_System/calculate_grade_screen.dart'; // Import the new screen

class AdminHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        title: const Text(
          'Admin Home',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManageAttendanceScreen(),
                ),
              ),
              child: const Text('Manage Attendance'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewLeaveRequestsScreen(),
                ),
              ),
              child: const Text('View Leave Requests'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SystemWideReportScreen(),
                ),
              ),
              child: const Text('Generate System-Wide Reports'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserSpecificReportScreen(),
                ),
              ),
              child: const Text('Generate User-Specific Reports'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalculateGradeScreen(),
                ),
              ),
              child: const Text('Manage Grading System'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewAllUsersScreen(),
                ),
              ),
              child: const Text('View All Users'),
            ),
          ],
        ),
      ),
    );
  }
}
