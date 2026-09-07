import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_colors.dart';
import 'core/services/native_bridge.dart';
import 'features/budget/repository/budget_repository.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/quick_log/quick_log_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dark translucent system status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final repository = BudgetRepository();
  await repository.loadData();

  final initialAction = await NativeBridge.instance.getInitialAction();

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
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.danger,
        ),
        fontFamily: 'Roboto',
      ),
      home: DashboardScreen(repository: widget.repository),
    );
  }
}
