import 'package:flutter/material.dart';
import 'user_state.dart';

class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userState = UserState();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blue.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(
              userState.isLoggedIn
                  ? 'Welcome, ${userState.username}'
                  : 'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          if (userState.isLoggedIn) ...[
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                if (userState.isAdmin) {
                  Navigator.pushReplacementNamed(context, '/admin-dashboard');
                } else {
                  Navigator.pushReplacementNamed(context, '/user-dashboard');
                }
              },
            ),
            if (!userState.isAdmin) ...[
              ListTile(
                leading: Icon(Icons.task),
                title: Text('Tasks'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/task');
                },
              ),
              ListTile(
                leading: Icon(Icons.access_time),
                title: Text('Attendance'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/attendance');
                },
              ),
              ListTile(
                leading: Icon(Icons.assessment),
                title: Text('Performance'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/performance');
                },
              ),
            ],
            if (userState.isAdmin) ...[
              ListTile(
                leading: Icon(Icons.admin_panel_settings),
                title: Text('Admin'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/admin-dashboard');
                },
              ),
              ListTile(
                leading: Icon(Icons.person_add),
                title: Text('User Management'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/user-management');
                },
              ),
            ],
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Change Password'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/change-password');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                userState.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ],
      ),
    );
  }
}
