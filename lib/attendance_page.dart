import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'db_helper.dart';
import 'user_state.dart';
import 'theme.dart';
import 'sidebar.dart';

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final DBHelper dbHelper = DBHelper();
  List<Map<String, dynamic>> attendanceHistory = [];
  bool? attendanceMarked;
  String? attendanceMessage;
  List<_AttendanceData> attendanceData = [];

  @override
  void initState() {
    super.initState();
    _loadAttendanceHistory();
    _checkAttendance();
  }

  Future<void> _loadAttendanceHistory() async {
    String username = UserState().username!;
    List<Map<String, dynamic>> history = await dbHelper.getAttendance(username);
    setState(() {
      attendanceHistory = history;
      attendanceData = history
          .map((record) => _AttendanceData(record['date'], record['isPresent'] == 1))
          .toList();
    });
  }

  Future<void> _checkAttendance() async {
    String username = UserState().username!;
    bool isMarked = await dbHelper.checkAttendanceForToday(username);
    setState(() {
      attendanceMarked = isMarked;
      attendanceMessage = isMarked
          ? 'Attendance already marked for today'
          : 'You can mark your attendance for today';
    });
  }

  Future<void> _markAttendance() async {
    String username = UserState().username!;
    await dbHelper.markAttendanceForToday(username, true);
    _checkAttendance();
    _loadAttendanceHistory();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Attendance'),
        ),
        drawer: Sidebar(),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Mark Attendance',
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
                'Attendance History',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  title: ChartTitle(text: 'Attendance Over Time'),
                  legend: Legend(isVisible: false),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CartesianSeries<_AttendanceData, String>>[
                    LineSeries<_AttendanceData, String>(
                      dataSource: attendanceData,
                      xValueMapper: (_AttendanceData data, _) => data.date,
                      yValueMapper: (_AttendanceData data, _) => data.isPresent ? 1 : 0,
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

class _AttendanceData {
  _AttendanceData(this.date, this.isPresent);

  final String date;
  final bool isPresent;
}
