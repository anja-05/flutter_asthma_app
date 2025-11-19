import 'package:Asthma_Assist/screens/emergency_plan_screen.dart';
import 'package:Asthma_Assist/screens/medictaion_plan_screen.dart';
import 'package:Asthma_Assist/screens/peak_flow_screen.dart';
import 'package:Asthma_Assist/screens/warnings_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'constants/app_colors.dart';
import 'services/auth_service.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/vital_data_screen.dart';
import 'screens/symptom_diary_screen.dart';
import 'screens/fhir_observation_screen.dart';
// Falls du später mehr Screens hast:
// import 'screens/emergency_screen.dart';
// import 'screens/medication_screen.dart';
// import 'screens/peakflow_screen.dart';
// import 'screens/warning_screen.dart';

// Fitbit App authentifizieren
import 'package:flutter/material.dart';
import 'package:fitbitter/fitbitter.dart';  // Importiert das fitbitter-Paket


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('de_DE', null);

  runApp(const AsthmaApp());
}

class AsthmaApp extends StatelessWidget {
  const AsthmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asthma App',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primaryColor: AppColors.primaryGreen,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
      ),

      // ALLE ROUTES DER APP
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/login': (context) => const LoginScreen(),

        // fertige Screens
        '/symptoms': (context) => const SymptomDiaryScreen(),
        '/vitals': (context) => const VitalScreen(),
        '/emergency': (context) => const EmergencyPlanScreen(),
        '/peakflow': (context) => const PeakFlowScreen(),
        '/medication': (context) => const MedicationScreen(),
        '/warnings': (context) => const WarningScreen(),
      },

      // App startet in Login/Dashboard je nach Auth
      home: const AuthWrapper(),
    );
  }
}

/// Prüft ob User eingeloggt ist
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService().isLoggedIn(),
      builder: (context, snapshot) {
        // Ladezustand
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Navigation abhängig vom Login
        if (snapshot.data == true) {
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
