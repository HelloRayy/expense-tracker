import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_colors.dart';
import 'core/services/native_bridge.dart';
import 'features/budget/repository/budget_repository.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/quick_log/quick_log_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  if (!kIsWeb) {
    // Dark translucent system status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  final repository = BudgetRepository();
  await repository.loadData();

  final initialAction = kIsWeb ? null : await NativeBridge.instance.getInitialAction();

  runApp(JajanApp(
    repository: repository,
    initialAction: initialAction,
  ));
}

class JajanApp extends StatefulWidget {
  final BudgetRepository repository;
  final String? initialAction;

  const JajanApp({
    super.key,
    required this.repository,
    this.initialAction,
  });

  @override
  State<JajanApp> createState() => _JajanAppState();
}

class _JajanAppState extends State<JajanApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      NativeBridge.instance.setActionListener((action) {
        if (action == 'ACTION_QUICK_LOG') {
          _openQuickLogDirectly();
        }
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialAction == 'ACTION_QUICK_LOG') {
        _openQuickLogDirectly();
      }
    });
  }

  void _openQuickLogDirectly() {
    final ctx = _navigatorKey.currentContext;
    if (ctx != null) {
      QuickLogDialog.show(
        ctx,
        repository: widget.repository,
        onComplete: () {
          // If launched purely from widget quick-log, minimize or stay
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Jajan Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: PirschColors.lightBg,
        primaryColor: PirschColors.accessibleGreen,
        colorScheme: const ColorScheme.light(
          primary: PirschColors.accessibleGreen,
          secondary: PirschColors.accessibleAmber,
          surface: PirschColors.lightCard,
          error: PirschColors.accessibleCrimson,
        ),
        fontFamily: 'Inter',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: PirschColors.darkBg,
        primaryColor: PirschColors.mintGreen,
        colorScheme: const ColorScheme.dark(
          primary: PirschColors.mintGreen,
          secondary: PirschColors.warmYellow,
          surface: PirschColors.darkCard,
          error: PirschColors.roseRed,
        ),
        fontFamily: 'Inter',
      ),
      home: DashboardScreen(repository: widget.repository),
    );
  }
}
