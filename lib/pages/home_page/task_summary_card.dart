import 'package:flutter/material.dart';
import 'package:todo/theme.dart';
import 'package:todo/helper/database_helper.dart';

class TaskSummaryCard extends StatefulWidget {
  const TaskSummaryCard({Key? key}) : super(key: key);

  @override
  _TaskSummaryCardState createState() => _TaskSummaryCardState();
}

class _TaskSummaryCardState extends State<TaskSummaryCard> {
  Map<String, int> taskSummary = {
    'total': 0,
    'completed': 0,
    'inProgress': 0,
    'overdue': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadTaskSummary();
  }

  Future<void> _loadTaskSummary() async {
    final summary = await DatabaseHelper.instance.getTaskSummary();
    setState(() {
      taskSummary = summary;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Container(
        decoration: AppTheme.glassomorphicDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Summary',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Tasks:',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Completed:',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('In Progress:',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Overdue:',
                        style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${taskSummary['total']}',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: AppTheme.cyan),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${taskSummary['completed']}',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: Colors.green),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${taskSummary['inProgress']}',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: Colors.orange),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${taskSummary['overdue']}',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
