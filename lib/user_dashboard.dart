import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'user_state.dart';
import 'theme.dart';
import 'sidebar.dart';

class UserDashboard extends StatefulWidget {
  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final DBHelper dbHelper = DBHelper();
  List<Map<String, dynamic>> tasks = [];
  bool? attendanceMarked;
  String? attendanceMessage;
  double taskCompletionRate = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _checkAttendance();
    _calculatePerformance();
  }

  Future<void> _loadTasks() async {
    String username = UserState().username!;
    List<Map<String, dynamic>> taskList = await dbHelper.getTasksForUser(username);
    setState(() {
      tasks = taskList;
    });
  }

  Future<void> _checkAttendance() async {
    String username = UserState().username!;
    bool isMarked = await dbHelper.checkAttendanceForToday(username);
    setState(() {
      attendanceMarked = isMarked;
      attendanceMessage = isMarked ? 'Attendance already marked for today' : 'You can mark your attendance for today';
    });
  }

  Future<void> _markAttendance() async {
    String username = UserState().username!;
    await dbHelper.markAttendanceForToday(username, true);
    _checkAttendance();
  }

  Future<void> _calculatePerformance() async {
    String username = UserState().username!;
    double completionRate = await dbHelper.calculateTaskCompletionRate(username);
    setState(() {
      taskCompletionRate = completionRate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text('User Dashboard'),
        ),
        drawer: Sidebar(),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Tasks',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(tasks[index]['task']),
                      subtitle: Text('Status: ${tasks[index]['status']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () async {
                          await dbHelper.updateTaskStatus(tasks[index]['id'], 'Completed');
                          _loadTasks();
                          _calculatePerformance();
                        },
                      ),
                    );
                  },
                ),
              ),
              Divider(),
              Text(
                'Attendance',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              attendanceMarked == null
                  ? CircularProgressIndicator()
                  : attendanceMarked!
                  ? Text(attendanceMessage!)
                  : ElevatedButton(
                onPressed: _markAttendance,
                child: Text('Mark Attendance'),
              ),
              Divider(),
              Text(
                'Performance Summary',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Task Completion Rate: ${(taskCompletionRate * 100).toStringAsFixed(2)}%'),
            ],
          ),
        ),
      ),
    );
  }
}
