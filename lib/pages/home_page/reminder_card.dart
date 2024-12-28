import 'package:flutter/material.dart';
import 'package:todo/theme.dart';
import 'package:todo/helper/database_helper.dart';
import 'package:intl/intl.dart';

class ReminderCard extends StatefulWidget {
  const ReminderCard({Key? key}) : super(key: key);

  @override
  _ReminderCardState createState() => _ReminderCardState();
}

class _ReminderCardState extends State<ReminderCard> {
  List<Map<String, dynamic>> reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final loadedReminders = await DatabaseHelper.instance.getReminders();
    setState(() {
      reminders = loadedReminders;
    });
  }

  Future<void> _addReminder() async {
    final TextEditingController titleController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text(
                'Add Reminder',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: "Reminder Title",
                        hintStyle: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setDialogState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cyan,
                      ),
                      child: const Text('Select Date'),
                    ),
                    if (selectedDate != null) // Show date under the button
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Selected Date: ${DateFormat('MMM dd, yyyy').format(selectedDate!)}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setDialogState(() {
                            selectedTime = pickedTime;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cyan,
                      ),
                      child: const Text('Select Time'),
                    ),
                    if (selectedTime != null) // Show time under the button
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Selected Time: ${selectedTime!.format(context)}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (titleController.text.isNotEmpty &&
                        selectedDate != null &&
                        selectedTime != null) {
                      final reminderDateTime = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        selectedTime!.hour,
                        selectedTime!.minute,
                      );
                      await DatabaseHelper.instance.insertReminder({
                        'title': titleController.text,
                        'dateTime': reminderDateTime.toIso8601String(),
                      });
                      Navigator.of(context).pop();
                      _loadReminders();
                    }
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(color: AppTheme.cyan),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reminders',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                IconButton(
                  onPressed: _addReminder,
                  icon: Icon(Icons.add_circle_outline,
                      color: AppTheme.cyan, size: 30.0),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                physics:
                    NeverScrollableScrollPhysics(), // Disable internal scrolling
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  final reminder = reminders[index];
                  final dateTime = DateTime.parse(reminder['dateTime']);
                  return ListTile(
                    title: Text(
                      reminder['title'],
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete,
                          color: Theme.of(context).colorScheme.error),
                      onPressed: () async {
                        await DatabaseHelper.instance
                            .deleteReminder(reminder['id']);
                        _loadReminders();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
