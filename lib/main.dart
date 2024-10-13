import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'login_page.dart';
import 'user_dashboard.dart';
import 'admin_dashboard.dart';
import 'admin_login_page.dart';
import 'user_state.dart';
import 'theme.dart';
import 'registration_page.dart';
import 'attendance_page.dart';
import 'task_page.dart';
import 'performance_page.dart';
import 'change_password_page.dart';
import 'user_management_page.dart';

void main() {
  if (isDesktop()) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(MyApp());
}

bool isDesktop() {
  return (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Performance Tracker',
      theme: appTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/registration': (context) => RegistrationPage(),
        '/user-dashboard': (context) => UserDashboard(),
        '/admin-dashboard': (context) => AdminDashboard(),
        '/admin-login': (context) => AdminLoginPage(),
        '/attendance': (context) => AttendancePage(),
        '/task': (context) => TaskPage(),
        '/performance': (context) => PerformancePage(),
        '/change-password': (context) => ChangePasswordPage(),
        '/user-management': (context) => UserManagementPage(), // Add this route
      },
    );
  }
}
