import 'package:fitbitter/fitbitter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../constants/app_colors.dart';
import '../widgets/dashboard/dashboard_card.dart';
import '../widgets/dashboard/greeting_header.dart';
import '../widgets/common/bottom_navigation.dart';

import '../services/auth_service.dart';
import '../models/user.dart';
import 'login_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('de_DE', null);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abmelden'),
        content: const Text('Möchten Sie sich wirklich abmelden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Abmelden'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  // FITBIT AUTH-FUNKTION
  Future<void> _connectFitbit() async {
    try {
      FitbitCredentials? fitbitCredentials = await FitbitConnector.authorize(
        clientID: '23TQ8M',
        clientSecret: 'b6c85177c8b0c82babec097bc6c47141',
        redirectUri: 'asthmaassist://fitbit-auth',
        callbackUrlScheme: 'asthmaassist',
      );

      if (fitbitCredentials != null) {
        print("Fitbit-Login erfolgreich!");
        print("UserID: ${fitbitCredentials.userID}");
        print("Token: ${fitbitCredentials.fitbitAccessToken}");

        // Herzfrequenz abrufen
        _getHeartRate(fitbitCredentials);
      }
    } catch (e) {
      print("Fehler bei Fitbit-Authentifizierung: $e");
    }
  }


  // HERZFREQUENZ ABRUFEN
  Future<void> _getHeartRate(FitbitCredentials fitbitCredentials) async {
    try {
      // Manager für Heart Rate erstellen
      FitbitHeartDataManager heartManager = FitbitHeartDataManager(
        clientID: '23TQ8M',
        clientSecret: 'b6c85177c8b0c82babec097bc6c47141',
      );

      // URL-Objekt für die Abfrage (Herzfrequenz eines Tages)
      FitbitHeartRateAPIURL heartRateUrl = FitbitHeartRateAPIURL.day(
        date: DateTime.now(),
        fitbitCredentials: fitbitCredentials,
      );
      //FitbitHeartRateAPIURL heartRateUrl = FitbitHeartRateAPIURL.day(fitbitCredentials: fitbitCredentials, date: DateTime.now());

      // Daten abrufen
      List<FitbitData> fitbitData =
      await heartManager.fetch(heartRateUrl);

      if (fitbitData == null || fitbitData.isEmpty) {
        print("Keine Daten von Fitbit erhalten.");
        return;
      }

      List<FitbitHeartRateData> heartData =
      fitbitData.map((data) => data as FitbitHeartRateData).toList();

      if (heartData.isEmpty) {
        print("Keine Herzfrequenzdaten gefunden.");
        return;
      }

      print("Herzfrequenzdaten:");
      for (var entry in heartData) {
        final restingHR = entry.restingHeartRate?.toString() ?? 'N/A';
        print(
            "Datum: ${entry.dateOfMonitoring} ➝ Ruhepuls: $restingHR bpm");
      }
    } catch (e) {
      print("Fehler beim Abrufen der Herzfrequenz: $e");
    }
  }


  void _navigateToScreen(String name) {
    switch (name) {
      case 'Symptomtagebuch':
        Navigator.pushNamed(context, '/symptoms');
        break;

      case 'Peak-Flow':
        Navigator.pushNamed(context, '/peakflow');
        break;

      case 'Medikationsplan':
        Navigator.pushNamed(context, '/medication');
        break;

      case 'Warnungen':
        Navigator.pushNamed(context, '/warnings');
        break;

      case 'Notfall':
        Navigator.pushNamed(context, '/emergency');
        break;

      case 'Vitaldaten':
        Navigator.pushNamed(context, '/vitals');
        break;

      default:
        debugPrint("Keine Route für: $name");
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      /// >>> BOTTOM NAVIGATION HINZUGEFÜGT <<<
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 0,
        onTap: (index) {
          // Kann später zu Screens navigieren
        },
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// >>> GREETING HEADER HINZUGEFÜGT <<<
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GreetingHeader(
                      userName: _currentUser?.displayName ?? "Gast",
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      color: AppColors.primaryGreen,
                      onPressed: _handleLogout,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                DashboardCard(
                  title: 'Symptomtagebuch',
                  icon: Icons.book,
                  iconColor: AppColors.lightGreen,
                  backgroundColor: AppColors.symptomCardBg,
                  content: 'Letzter Eintrag: 20.10.2025\nTrend: Weniger Anfälle',
                  onTap: () => _navigateToScreen('Symptomtagebuch'),
                ),
                const SizedBox(height: 16),

                DashboardCard(
                  title: 'Peak-Flow',
                  icon: Icons.show_chart,
                  iconColor: AppColors.mediumGreen,
                  backgroundColor: AppColors.peakFlowCardBg,
                  content: 'Letzte Messung: 350 l/min\nIm grünen Bereich',
                  onTap: () => _navigateToScreen('Peak-Flow'),
                ),
                const SizedBox(height: 16),

                DashboardCard(
                  title: 'Medikationsplan',
                  icon: Icons.medication,
                  iconColor: AppColors.primaryGreen,
                  backgroundColor: AppColors.medicationCardBg,
                  content: 'Nächstes Medikament: 18:00 Uhr\nKeine Doppeldosierung',
                  onTap: () => _navigateToScreen('Medikationsplan'),
                ),
                const SizedBox(height: 16),

                DashboardCard(
                  title: 'Warnungen',
                  icon: Icons.warning_amber,
                  iconColor: AppColors.darkGreen,
                  backgroundColor: AppColors.warningCardBg,
                  content: 'Pollen: Hoch\nLuftqualität: Gut',
                  onTap: () => _navigateToScreen('Warnungen'),
                ),
                const SizedBox(height: 16),

                DashboardCard(
                  title: 'Notfall',
                  icon: Icons.phone,
                  iconColor: AppColors.emergencyRed,
                  backgroundColor: AppColors.emergencyCardBg,
                  content: 'Notfallplan bereit\nSOS-Button verfügbar',
                  onTap: () => _navigateToScreen('Notfall'),
                ),
                const SizedBox(height: 16),

                DashboardCard(
                  title: 'Vitaldaten',
                  icon: Icons.favorite,
                  iconColor: AppColors.tealAccent,
                  backgroundColor: AppColors.vitalCardBg,
                  content:
                  'Puls: 72 bpm\nSauerstoff: 98%\nAtemfrequenz: 14/min',
                  onTap: () => _navigateToScreen('Vitaldaten'),
                ),

                //FITBIT BUTTON
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: _connectFitbit,
                  icon: const Icon(Icons.watch),
                  label: const Text("Mit Fitbit verbinden"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
