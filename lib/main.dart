import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'providers/advice_provider.dart';
import 'providers/condition_provider.dart';
import 'providers/disruption_provider.dart';
import 'providers/plan_provider.dart';
import 'providers/profile_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storage = StorageService(prefs);

  runApp(PapetuneApp(storage: storage));
}

class PapetuneApp extends StatelessWidget {
  final StorageService storage;

  const PapetuneApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storage),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(storage),
        ),
        ChangeNotifierProvider(
          create: (_) => DisruptionProvider(storage),
        ),
        ChangeNotifierProvider(
          create: (_) => ConditionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PlanProvider(storage),
        ),
        ChangeNotifierProvider(
          create: (_) => AdviceProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Papetune',
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) {
            final hasProfile = context.watch<ProfileProvider>().hasProfile;
            return hasProfile
                ? const DashboardScreen()
                : const OnboardingScreen();
          },
          '/onboarding': (context) => const OnboardingScreen(),
          '/dashboard': (context) => const DashboardScreen(),
        },
      ),
    );
  }
}
