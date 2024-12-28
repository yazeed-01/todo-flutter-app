import 'package:flutter/material.dart';
import 'package:todo/helper/database_helper.dart';
import 'package:todo/pages/tasks_page/add_task_dialog.dart';
import 'package:todo/pages/tasks_page/taskDetailPage.dart';
import 'package:todo/theme.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Map<String, dynamic>> tasks = [];
  String currentPage = 'Tasks';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final loadedTasks = await DatabaseHelper.instance.getTasks();
    setState(() {
      tasks = loadedTasks;
    });
  }

  Widget buildAppBarButton(BuildContext context, String label, String route) {
    bool isSelected = currentPage == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextButton(
        onPressed: () {
          setState(() {
            currentPage = label;
          });
          Navigator.pushReplacementNamed(context, route);
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            isSelected ? AppTheme.cyan : Colors.transparent,
          ),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppTheme.deepBlue
                : Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddTaskDialog();
      },
    ).then((_) => _loadTasks());
  }

  void _navigateToTaskDetail(int taskId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailPage(taskId: taskId),
      ),
    );
  }

  Future<void> _deleteTask(int id) async {
    await DatabaseHelper.instance.deleteTask(id);
    _loadTasks();
  }

  Future<void> _toggleTaskStatus(Map<String, dynamic> task) async {
    final updatedTask = Map<String, dynamic>.from(task);
    updatedTask['status'] =
        task['status'] == 'completed' ? 'inProgress' : 'completed';
    await DatabaseHelper.instance.updateTask(updatedTask);
    _loadTasks();
  }

  // sort tasks by by piority
  void _sortTasksByPriority() {
    setState(() {
      // Ensure we work with a mutable copy of the tasks list
      List<Map<String, dynamic>> mutableTasks = List.from(tasks);

      // Define a map for converting priority levels to numeric values
      Map<String, int> priorityMap = {
        'Low': 3,
        'Medium': 2,
        'High': 1,
      };

      // Sort tasks first by status (incomplete first) then by priority
      mutableTasks.sort((a, b) {
        // Sort by status: incomplete tasks first ('inProgress' < 'completed')
        int statusComparison = (a['status'] == 'completed' ? 1 : 0)
            .compareTo(b['status'] == 'completed' ? 1 : 0);

        if (statusComparison != 0) {
          return statusComparison;
        }

        // If status is the same, then sort by priority
        return priorityMap[a['priority']]!
            .compareTo(priorityMap[b['priority']]!);
      });

      // Update the state with the sorted tasks list
      tasks = mutableTasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _sortTasksByPriority, // Call the sorting function
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            height: 48,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  buildAppBarButton(context, 'Dashboard', '/'),
                  buildAppBarButton(context, 'Tasks', '/tasks'),
                  buildAppBarButton(context, 'Focus', '/focus'),
                  buildAppBarButton(context, 'Settings', '/settings'),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return GestureDetector(
                    onTap: () => _navigateToTaskDetail(task['id']),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          task['title'],
                          style: TextStyle(
                            decoration: task['status'] == 'completed'
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          task['description'] ?? '',
                          maxLines: 2,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(task['priority']),
                            Checkbox(
                              value: task['status'] == 'completed',
                              onChanged: (bool? value) {
                                _toggleTaskStatus(task);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteTask(task['id']),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          FloatingActionButton(
            onPressed: _showAddTaskDialog,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
