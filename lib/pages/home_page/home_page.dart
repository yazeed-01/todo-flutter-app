import 'package:flutter/material.dart';
import 'package:todo/pages/home_page/task_summary_card.dart';
import 'package:todo/pages/home_page/reminder_card.dart';
import 'package:todo/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentPage = 'Dashboard';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TODO'),
        backgroundColor: AppTheme.deepBlue,
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.background,
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
          const Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TaskSummaryCard(),
                    SizedBox(height: 16),
                    ReminderCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
