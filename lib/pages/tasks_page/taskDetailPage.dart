import 'package:flutter/material.dart';
import 'package:todo/helper/database_helper.dart';

class TaskDetailPage extends StatefulWidget {
  final int taskId;

  const TaskDetailPage({Key? key, required this.taskId}) : super(key: key);

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  Map<String, dynamic> task = {};

  @override
  void initState() {
    super.initState();
    _loadTaskDetails();
  }

  Future<void> _loadTaskDetails() async {
    final fetchedTask =
        await DatabaseHelper.instance.getTaskById(widget.taskId);
    setState(() {
      task = fetchedTask;
    });
  }

  Future<void> _toggleTaskStatus() async {
    final updatedTask = {...task};
    updatedTask['status'] =
        task['status'] == 'completed' ? 'inProgress' : 'completed';
    await DatabaseHelper.instance.updateTask(updatedTask);
    _loadTaskDetails(); // Reload task details
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the default back button
        title: Text(task['title'] ?? 'Task Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task['title'] ?? '',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              task['description'] ?? '',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Priority: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(task['priority'] ?? ''),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Status: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: task['status'] == 'completed',
                  onChanged: (bool value) {
                    _toggleTaskStatus();
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Created At: ${task['createdAt']}', // Display any other relevant task details
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, '/tasks'); // Back to the previous page
              },
              child: Text('Back to Task List'),
            ),
          ],
        ),
      ),
    );
  }
}
