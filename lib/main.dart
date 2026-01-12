import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// App intern
import 'constants/app_colors.dart';
import 'services/auth_service.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/vital_data_screen.dart';
import 'screens/symptom/symptom_diary_screen.dart';
import 'screens/emergency_plan_screen.dart';
import 'screens/medication_plan_screen.dart';
import 'screens/peak_flow_screen.dart';
import 'screens/warnings_screen.dart';
import 'screens/main_shell.dart';

// Fitbit
import 'package:fitbitter/fitbitter.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Firebase initialisieren (Backend)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// Lokalisierung
  await initializeDateFormatting('de_DE', null);

  /// Benachrichtigungen initialisieren
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const AsthmaApp());
}

class AsthmaApp extends StatelessWidget {
  const AsthmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AsthmaAssist',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primaryColor: AppColors.primaryGreen,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
        ),
      ),

      /// Zentrale Routen (unverändert)
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),

        '/symptoms': (context) => const SymptomDiaryScreen(),
        '/vitals': (context) => const VitalScreen(),
        '/emergency': (context) => const EmergencyPlanScreen(),
        '/peakflow': (context) => const PeakFlowScreen(),
        '/medication': (context) => const MedicationScreen(),
        '/warnings': (context) => const WarningScreen(),
      },

      /// Einstiegspunkt abhängig vom Firebase-Auth-Status
      home: const AuthWrapper(),
    );
  }
}

/// Entscheidet automatisch Login vs. Dashboard
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const MainShell();
        }

        return const LoginScreen();
      },
    );
  }
}
