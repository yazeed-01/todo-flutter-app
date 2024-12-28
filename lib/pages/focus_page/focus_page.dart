import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../theme.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({Key? key}) : super(key: key);

  @override
  _FocusPageState createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  bool isActive = false;
  int time = 25 * 60; // 25 minutes in seconds
  String timerType = 'pomodoro';
  bool isMuted = false;
  double volume = 50;
  Timer? timer;
  String currentPage = 'Focus';
  int treesPlanted = 0;
  int consecutiveFocusSessions = 0;
  int totalFocusSessions = 0; // Track total sessions
  DateTime? lastSessionEndTime; // Track last session end time
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    loadProgress(); // Load progress from persistent storage
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void toggleTimer() {
    setState(() {
      isActive = !isActive;
      if (isActive) {
        timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) return; // Check if the widget is still mounted
          setState(() {
            if (time > 0) {
              time--;
            } else {
              isActive = false;
              timer.cancel();
              _showNotification();
              totalFocusSessions++;
              if (timerType == 'pomodoro') {
                treesPlanted++;
                consecutiveFocusSessions++;
              } else {
                consecutiveFocusSessions = 0;
              }
              saveProgress(); // Save progress when session ends
            }
          });
        });
      } else {
        timer?.cancel();
      }
    });
  }

  void resetTimer() {
    setState(() {
      isActive = false;
      timer?.cancel();
      time = getTimerDuration(timerType);
      consecutiveFocusSessions = 0;
      saveProgress(); // Save progress when resetting
    });
  }

  int getTimerDuration(String type) {
    switch (type) {
      case 'pomodoro':
        return 25 * 60;
      case 'short-break':
        return 5 * 60;
      case 'long-break':
        return 15 * 60;
      default:
        return 25 * 60;
    }
  }

  String formatTime(int timeInSeconds) {
    int minutes = timeInSeconds ~/ 60;
    int seconds = timeInSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'focus_timer_channel',
      'Focus Timer Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Focus Session Complete',
      'Great job! Take a break or start a new session.',
      platformChannelSpecifics,
    );
  }

  void _showStreakResetWarning() {
    if (consecutiveFocusSessions > 0 && consecutiveFocusSessions % 4 == 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Streak Broken'),
            content: Text('Your streak has ended. Stay focused and try again!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> saveProgress() async {
    // Store progress locally or in persistent storage
    // Example: Shared Preferences or a database
  }

  Future<void> loadProgress() async {
    // Load progress from persistent storage
    // Example: Shared Preferences or a database
    // Update treesPlanted, consecutiveFocusSessions, and totalFocusSessions
  }

  Future<void> showWeeklyAnalytics() async {
    // Calculate weekly analytics and show them in a dialog
    // Example: show total time, average session time, etc.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Mode'),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      decoration: AppTheme.glassomorphicDecoration,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          DropdownButton<String>(
                            value: timerType,
                            items: ['pomodoro', 'short-break', 'long-break']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  timerType = newValue;
                                  time = getTimerDuration(newValue);
                                  isActive = false;
                                  timer?.cancel();
                                  _showStreakResetWarning(); // Show warning on reset
                                });
                              }
                            },
                            dropdownColor: AppTheme.purple,
                            style: const TextStyle(color: AppTheme.cyan),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            formatTime(time),
                            style: const TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.cyan,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: toggleTimer,
                                child: Text(isActive ? 'Pause' : 'Start'),
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: resetTimer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                ),
                                child: const Text('Reset'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(isMuted
                                    ? Icons.volume_off
                                    : Icons.volume_up),
                                onPressed: () {
                                  setState(() {
                                    isMuted = !isMuted;
                                  });
                                },
                                color: AppTheme.cyan,
                              ),
                              Expanded(
                                child: Slider(
                                  value: volume,
                                  min: 0,
                                  max: 100,
                                  divisions: 100,
                                  label: volume.round().toString(),
                                  onChanged: (value) {
                                    setState(() => volume = value);
                                  },
                                  activeColor: AppTheme.cyan,
                                  inactiveColor: AppTheme.cyan.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text('Trees Planted: $treesPlanted',
                                style: const TextStyle(fontSize: 16)),
                            Text('Streak: $consecutiveFocusSessions',
                                style: const TextStyle(fontSize: 16)),
                            Text('Total Sessions: $totalFocusSessions',
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
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
