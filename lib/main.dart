import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'constants/app_colors.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/fhir_observation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisiere deutsche Lokalisierung
  await initializeDateFormatting('de_DE', null);

  runApp(const AsthmaApp());
}

class AsthmaApp extends StatelessWidget {
  const AsthmaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asthma App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryGreen,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ),
     // home: const AuthWrapper(),
      home: FhirObservationScreen(),
    );
  }
}

// AuthWrapper prüft ob User eingeloggt ist
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService().isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            ),
          );
        }

        // Wenn eingeloggt: Dashboard, sonst: Login
        if (snapshot.data == true) {
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}