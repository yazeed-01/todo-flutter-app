import 'package:flutter/material.dart';
import 'package:todo/pages/focus_page/focus_page.dart';
import 'package:todo/pages/tasks_page/tasks_page.dart';
import 'package:todo/widgets/custom_error_widget.dart';
import 'package:todo/pages/home_page/home_page.dart';
import 'package:todo/pages/settings_page/settings_page.dart';
import 'package:todo/theme.dart';
import 'package:todo/helper/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    runApp(ErrorWidgetClass(details));
  };

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _themeMode = 'system';
  String _startingPage = 'home';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final themeMode = await DatabaseHelper.instance.getSetting('theme_mode');
    final startingPage =
        await DatabaseHelper.instance.getSetting('starting_page');
    setState(() {
      _themeMode = themeMode ?? 'system';
      _startingPage = startingPage ?? 'home';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO',
      theme: AppTheme.lightTheme, // Use your light theme
      darkTheme: AppTheme.darkTheme, // Use your dark theme
      themeMode: _getThemeMode(), // Dynamically set the theme
      initialRoute: _getInitialRoute(), // Dynamically set the initial route
      routes: {
        '/': (context) => const HomePage(),
        '/tasks': (context) => const TaskPage(),
        '/settings': (context) => const SettingsPage(),
        '/focus': (context) => const FocusPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeMode _getThemeMode() {
    switch (_themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _getInitialRoute() {
    switch (_startingPage) {
      case 'tasks':
        return '/tasks';
      case 'focus':
        return '/focus';
      case 'settings':
        return '/settings';
      default:
        return '/';
    }
  }
}

// Error Widget
class ErrorWidgetClass extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const ErrorWidgetClass(this.errorDetails, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CustomErrorWidget(
        errorMessage: errorDetails.exceptionAsString(),
      ),
    );
  }
}
