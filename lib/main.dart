import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

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
import 'screens/symptom_diary_screen.dart';
import 'screens/emergency_plan_screen.dart';
import 'screens/medication_plan_screen.dart';
import 'screens/peak_flow_screen.dart';
import 'screens/warnings_screen.dart';
import 'screens/fhir_observation_screen.dart';

// Fitbit (bleibt unberührt)
import 'package:fitbitter/fitbitter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 🔹 Firebase initialisieren (Backend)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// 🔹 Lokalisierung
  await initializeDateFormatting('de_DE', null);

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

      /// 🔹 Zentrale Routen (unverändert)
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),

        '/symptoms': (context) => const SymptomDiaryScreen(),
        '/vitals': (context) => const VitalScreen(),
        '/emergency': (context) => const EmergencyPlanScreen(),
        '/peakflow': (context) => const PeakFlowScreen(),
        '/medication': (context) => const MedicationScreen(),
        '/warnings': (context) => const WarningScreen(),
        '/fhir': (context) => const FhirObservationScreen(),
      },

      /// 🔹 Einstiegspunkt abhängig vom Firebase-Auth-Status
      home: const AuthWrapper(),
    );
  }
}

/// 🔐 Entscheidet automatisch Login vs. Dashboard
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // 🔄 Ladezustand
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ Eingeloggt → Dashboard
        if (snapshot.hasData) {
          return const DashboardScreen();
        }

        // ❌ Nicht eingeloggt → Login
        return const LoginScreen();
      },
    );
  }
}
