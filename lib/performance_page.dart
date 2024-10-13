import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'db_helper.dart';
import 'user_state.dart';
import 'theme.dart';
import 'sidebar.dart';

class PerformancePage extends StatefulWidget {
  @override
  _PerformancePageState createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  final DBHelper dbHelper = DBHelper();
  double taskCompletionRate = 0.0;
  List<_TaskData> taskData = [];

  @override
  void initState() {
    super.initState();
    _calculatePerformance();
  }

  Future<void> _calculatePerformance() async {
    String username = UserState().username!;
    double completionRate = await dbHelper.calculateTaskCompletionRate(username);
    List<Map<String, dynamic>> tasks = await dbHelper.getPerformance(username);

    setState(() {
      taskCompletionRate = completionRate;
      taskData = tasks
          .map((task) => _TaskData(task['task'], task['status'] == 'Completed' ? 1 : 0))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Performance'),
        ),
        drawer: Sidebar(),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Performance Summary',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Task Completion Rate: ${(taskCompletionRate * 100).toStringAsFixed(2)}%',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Expanded(
                child: SfCircularChart(
                  title: ChartTitle(text: 'Task Completion Status'),
                  legend: Legend(isVisible: true),
                  series: <CircularSeries>[
                    PieSeries<_TaskData, String>(
                      dataSource: taskData,
                      xValueMapper: (_TaskData data, _) => data.task,
                      yValueMapper: (_TaskData data, _) => data.status,
                      dataLabelMapper: (_TaskData data, _) =>
                      '${data.task}: ${data.status == 1 ? 'Completed' : 'Pending'}',
                      dataLabelSettings: DataLabelSettings(isVisible: true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskData {
  _TaskData(this.task, this.status);

  final String task;
  final int status;
}
