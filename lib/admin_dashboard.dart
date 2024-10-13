import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'db_helper.dart';
import 'theme.dart';
import 'sidebar.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final DBHelper dbHelper = DBHelper();
  final TextEditingController _taskController = TextEditingController();
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> attendanceData = [];
  int? selectedUserId;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadAttendanceData();
  }

  Future<void> _loadUsers() async {
    List<Map<String, dynamic>> userList = await dbHelper.getAllUsers();
    setState(() {
      users = userList;
    });
  }

  Future<void> _loadAttendanceData() async {
    List<Map<String, dynamic>> data = await dbHelper.getAttendanceData();
    setState(() {
      attendanceData = data;
    });
  }

  Future<void> _assignTask() async {
    if (selectedUserId != null && _taskController.text.isNotEmpty) {
      await dbHelper.insertTask(selectedUserId!, _taskController.text, 'Pending', 0);
      _taskController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task assigned successfully')),
      );
    }
  }

  Future<void> _loadUserTasks(int userId) async {
    List<Map<String, dynamic>> taskList = await dbHelper.getTasks(userId);
    setState(() {
      tasks = taskList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Dashboard'),
        ),
        drawer: Sidebar(),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Assign Task',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                DropdownButton<int>(
                  value: selectedUserId,
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedUserId = newValue;
                    });
                    _loadUserTasks(newValue!);
                  },
                  items: users.map<DropdownMenuItem<int>>((Map<String, dynamic> user) {
                    return DropdownMenuItem<int>(
                      value: user['id'],
                      child: Text(user['username']),
                    );
                  }).toList(),
                ),
                TextField(
                  controller: _taskController,
                  decoration: InputDecoration(
                    labelText: 'Task',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _assignTask,
                  child: Text('Assign Task'),
                ),
                Divider(),
                Text(
                  'Tasks for Selected User',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(tasks[index]['task']),
                      subtitle: Text('Status: ${tasks[index]['status']}'),
                    );
                  },
                ),
                Divider(),
                Text(
                  'Attendance Tracker',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  series: <CartesianSeries>[
                    LineSeries<Map<String, dynamic>, String>(
                      dataSource: attendanceData,
                      xValueMapper: (Map<String, dynamic> data, _) => data['date'],
                      yValueMapper: (Map<String, dynamic> data, _) => data['isPresent'],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
