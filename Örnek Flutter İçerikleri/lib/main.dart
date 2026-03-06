import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'providers/app_state.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF141414),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Check if launched from widget
  final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
  final openAddNote = _isAddNoteUri(initialUri);

  runApp(DevNoteApp(openAddNote: openAddNote));
}

bool _isAddNoteUri(Uri? uri) {
  if (uri == null) return false;
  return (uri.scheme == 'devnote' && uri.host == 'addnote') ||
      uri.toString().toLowerCase().contains('addnote');
}

@pragma('vm:entry-point')
Future<void> interactiveCallback(Uri? uri) async {}

class DevNoteApp extends StatefulWidget {
  final bool openAddNote;

  const DevNoteApp({super.key, this.openAddNote = false});

  @override
  State<DevNoteApp> createState() => _DevNoteAppState();
}

class _DevNoteAppState extends State<DevNoteApp> {
  final AppState _appState = AppState();
  StreamSubscription<Uri?>? _widgetSub;

  @override
  void initState() {
    super.initState();
    _appState.addListener(_onStateChanged);

    // Listen for widget clicks while app is running
    HomeWidget.registerInteractivityCallback(interactiveCallback);
    _widgetSub = HomeWidget.widgetClicked.listen((uri) {
      if (_isAddNoteUri(uri)) {
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => _AddNoteRoute(appState: _appState),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _appState.removeListener(_onStateChanged);
    _widgetSub?.cancel();
    super.dispose();
  }

  void _onStateChanged() {
    setState(() {});
  }

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevNote',
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF0D0D0D),
          primary: Colors.white,
          onPrimary: Colors.black,
        ),
        fontFamily: 'Roboto',
      ),
      home: HomeScreen(
        appState: _appState,
        openAddNote: widget.openAddNote,
      ),
    );
  }
}

/// Temporary route that shows the HomeScreen and immediately opens the add note sheet
class _AddNoteRoute extends StatefulWidget {
  final AppState appState;
  const _AddNoteRoute({required this.appState});

  @override
  State<_AddNoteRoute> createState() => _AddNoteRouteState();
}

class _AddNoteRouteState extends State<_AddNoteRoute> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Pop this route and let HomeScreen handle the sheet
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen(appState: widget.appState, openAddNote: true);
  }
}
