import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/helper/database_helper.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({Key? key}) : super(key: key);

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  String taskTitle = '';
  String taskDescription = '';
  String priority = 'Low';
  DateTime? dueDate;
  List<String> tags = [];
  final TextEditingController tagController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();

  Future<void> _saveTask() async {
    if (taskTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task title is required')),
      );
      return;
    }

    final Map<String, dynamic> task = {
      'title': taskTitle,
      'description': taskDescription,
      'priority': priority,
      'dueDate': dueDate != null ? dueDate!.toIso8601String() : null,
      'tags': tags.isNotEmpty ? tags.join(', ') : null,
    };

    await DatabaseHelper.instance.insertTask(task);

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task added successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Task',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      hint: 'Enter task title',
                      onChanged: (value) => taskTitle = value,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      hint: 'Enter task description',
                      onChanged: (value) => taskDescription = value,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildPriorityDropdown(),
                    const SizedBox(height: 16),
                    _buildDueDateField(),
                    const SizedBox(height: 16),
                    _buildTagsField(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _saveTask,
                  child: const Text('Save Task'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required Function(String) onChanged,
    int maxLines = 1,
  }) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      onChanged: onChanged,
    );
  }

  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<String>(
      value: priority,
      decoration: const InputDecoration(
        labelText: 'Priority',
        border: OutlineInputBorder(),
      ),
      items: ['Low', 'Medium', 'High'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          priority = newValue ?? 'Low';
        });
      },
    );
  }

  Widget _buildDueDateField() {
    return TextField(
      controller: dueDateController,
      decoration: const InputDecoration(
        labelText: 'Due Date',
        border: OutlineInputBorder(),
      ),
      readOnly: true,
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            dueDate = pickedDate;
            dueDateController.text =
                DateFormat('yyyy-MM-dd').format(pickedDate);
          });
        }
      },
    );
  }

  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: tagController,
          decoration: const InputDecoration(
            labelText: 'Add Tag',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            if (tagController.text.isNotEmpty) {
              setState(() {
                tags.add(tagController.text);
                tagController.clear();
              });
            }
          },
          child: const Text('Add Tag'),
        ),
        Wrap(
          spacing: 8.0,
          children: tags
              .map(
                (tag) => Chip(
                  label: Text(tag),
                  onDeleted: () {
                    setState(() {
                      tags.remove(tag);
                    });
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
