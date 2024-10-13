import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'user_state.dart';
import 'theme.dart';
import 'sidebar.dart';

class ChangePasswordPage extends StatelessWidget {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final DBHelper dbHelper = DBHelper();

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Change Password'),
        ),
        drawer: Sidebar(),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Change Password',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _currentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    String username = UserState().username!;
                    String currentPassword = _currentPasswordController.text;
                    String newPassword = _newPasswordController.text;

                    bool isValidUser = await dbHelper.validateUser(username, currentPassword, UserState().isAdmin);
                    if (isValidUser) {
                      await dbHelper.updatePassword(username, newPassword);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Password changed successfully')),
                      );
                      Navigator.pushReplacementNamed(context, UserState().isAdmin ? '/admin-dashboard' : '/user-dashboard');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Current password is incorrect')),
                      );
                    }
                  },
                  child: Text('Change Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
