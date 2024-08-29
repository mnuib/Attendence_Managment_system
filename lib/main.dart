import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Screens/Admin_Penal/Admin_Home_Screen/admin_home_screen.dart';
import 'Screens/Admin_Penal/Admin_Login_Screen/admin_login_screen.dart';
import 'Screens/User_Penal/Edit_profile/edit_profile_screen.dart';
import 'Screens/User_Penal/Login_Screen/login_screen.dart';
import 'Screens/User_Penal/Registeration_Sccreen/registration_screen.dart';
import 'Screens/User_Penal/User_Home_Screen/user_home_screen.dart';
import 'Screens/User_Penal/View_Attendence/view_attendence_screen.dart';
import 'Screens/User_Penal/Mark_Leav/mark_leave_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Management System',
      initialRoute: '/register',
      routes: {
        '/register': (context) => UserRegistrationScreen(),
        '/user_login': (context) => UserLoginScreen(),
        '/user_home': (context) => UserHomeScreen(),
        '/view_attendance': (context) => ViewAttendanceScreen(),
        '/edit_profile': (context) => EditProfileScreen(),
        '/send_leave_request': (context) => SendLeaveRequestScreen(),
        '/admin_login': (context) => AdminLoginScreen(),
        '/admin_home': (context) => AdminHomeScreen(),
      },
    );
  }
}
