import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'user_state.dart';
import 'theme.dart';
import 'sidebar.dart';

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final DBHelper dbHelper = DBHelper();
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    String username = UserState().username!;
    List<Map<String, dynamic>> taskList = await dbHelper.getTasksForUser(username);
    setState(() {
      tasks = taskList;
    });
  }

  Future<void> _updateTaskStatus(int taskId, String status) async {
    await dbHelper.updateTaskStatus(taskId, status);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tasks'),
        ),
        drawer: Sidebar(),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'My Tasks',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(tasks[index]['task']),
                      subtitle: Text('Status: ${tasks[index]['status']}'),
                      trailing: tasks[index]['status'] == 'Pending'
                          ? IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () async {
                          await _updateTaskStatus(tasks[index]['id'], 'Completed');
                        },
                      )
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
