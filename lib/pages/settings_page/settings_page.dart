import 'package:flutter/material.dart';
import 'package:todo/theme.dart';
import 'package:todo/helper/database_helper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notifications = true;
  double volume = 50;
  String currentPage = 'Settings';
  String selectedTheme = 'system';
  String startingPage = 'home';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final themeMode = await DatabaseHelper.instance.getSetting('theme_mode');
    final notificationsEnabled =
        await DatabaseHelper.instance.getSetting('notifications_enabled');
    final volumeLevel =
        await DatabaseHelper.instance.getSetting('volume_level');
    final startPage = await DatabaseHelper.instance.getSetting('starting_page');

    setState(() {
      selectedTheme = themeMode ?? 'system';
      notifications = notificationsEnabled == 'true';
      volume = double.parse(volumeLevel ?? '50');
      startingPage = startPage ?? 'home';
    });
  }

  Future<void> _saveSettings() async {
    await DatabaseHelper.instance.setSetting('theme_mode', selectedTheme);
    await DatabaseHelper.instance
        .setSetting('notifications_enabled', notifications.toString());
    await DatabaseHelper.instance.setSetting('volume_level', volume.toString());
    await DatabaseHelper.instance.setSetting('starting_page', startingPage);
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
        title: const Text('Settings'),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: AppTheme.glassomorphicDecoration,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildThemeSelector(),
                        const SizedBox(height: 20),
                        _buildStartingPageSelector(),
                        const SizedBox(height: 20),
                        _buildSwitchTile('Notifications', notifications,
                            (value) {
                          setState(() => notifications = value);
                          _saveSettings();
                        }),
                        const SizedBox(height: 20),
                        Text('Sound Volume',
                            style: Theme.of(context).textTheme.titleLarge),
                        Slider(
                          value: volume,
                          min: 0,
                          max: 100,
                          divisions: 100,
                          label: volume.round().toString(),
                          onChanged: (value) {
                            setState(() => volume = value);
                            _saveSettings();
                          },
                          activeColor: AppTheme.cyan,
                          inactiveColor: AppTheme.cyan.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Theme', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        DropdownButton<String>(
          value: selectedTheme,
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedTheme = newValue;
              });
              _saveSettings();
            }
          },
          items: <String>['light', 'dark', 'system']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value.capitalize()),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStartingPageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Starting Page', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        DropdownButton<String>(
          value: startingPage,
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                startingPage = newValue;
              });
              _saveSettings();
            }
          },
          items: <String>['home', 'tasks', 'focus', 'settings']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value.capitalize()),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.cyan,
            activeTrackColor: AppTheme.cyan.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
