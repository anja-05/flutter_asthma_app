import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../widgets/dashboard/dashboard_card.dart';
import '../widgets/dashboard/greeting_header.dart';

import '../services/auth_service.dart';
import '../services/fitbit_service.dart';
import '../models/user.dart';
import 'login_screen.dart';

/// Zentrales Dashboard der App.
/// Dieser Screen dient als Hauptübersicht nach dem Login und ermöglicht den Zugriff auf alle Kernfunktionen der App:
/// - Symptomtagebuch
/// - Peak-Flow-Messungen
/// - Medikationsplan
/// - Warnungen
/// - Notfallplan
/// - Vitaldaten
///
/// Zusätzlich verwaltet das Dashboard:
/// - Benutzerbegrüßung
/// - Logout
/// - Benachrichtigungseinstellungen
/// - Fitbit-Verbindung
class DashboardScreen extends StatefulWidget {
  /// Erstellt einen neuen [DashboardScreen].
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

/// Zustandsklasse für den [DashboardScreen].
/// Enthält Logik für:
/// - Laden des aktuellen Benutzers
/// - Verwaltung von App-Einstellungen
/// - Navigation zu Unterseiten
/// - Systemberechtigungen (Benachrichtigungen)
class _DashboardScreenState extends State<DashboardScreen> {
  /// Service zur Authentifizierung und Benutzerverwaltung.
  final _authService = AuthService();
  /// Service zur Verbindung und Synchronisation mit Fitbit.
  final _fitbitService = FitbitService();
  /// Aktuell eingeloggter Benutzer.
  AppUser? _currentUser;
  /// Gibt an, ob Daten noch geladen werden.
  bool _isLoading = true;
  /// Aktueller Status der Benachrichtigungen innerhalb der App.
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    /// Initialisiert deutsche Datumsformate (z. B. für Begrüßung).
    initializeDateFormatting('de_DE', null);
    _loadUser();
    _loadNotificationPreference();
  }

  /// Lädt die gespeicherte Benachrichtigungseinstellung.
  /// Die Einstellung wird aus [SharedPreferences] gelesen und im lokalen State gespeichert.
  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    });
  }

  /// Lädt den aktuell angemeldeten Benutzer.
  /// Wird beim Initialisieren des Dashboards aufgerufen.
  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  /// Führt den Logout des Benutzers durch.
  /// Zeigt zuvor einen Bestätigungsdialog an und navigiert anschließend zurück zum [LoginScreen].
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

  /// Aktiviert oder deaktiviert Benachrichtigungen.
  /// Prüft Systemberechtigungen und speichert die Entscheidung dauerhaft in [SharedPreferences].
  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (value) {
      var status = await Permission.notification.status;
      
      if (status.isPermanentlyDenied) {
        if (mounted) {
          _showSettingsDialog();
          setState(() => _notificationsEnabled = false);
        }
        await prefs.setBool('notifications_enabled', false);
        return;
      }

      status = await Permission.notification.request();
      
      if (mounted) {
        setState(() {
          _notificationsEnabled = status.isGranted;
        });
        await prefs.setBool('notifications_enabled', status.isGranted);
        
        if (!status.isGranted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Benachrichtigungen wurden vom System abgelehnt.')),
          );
        }
      }
    } else {
      setState(() {
        _notificationsEnabled = false;
      });
      await prefs.setBool('notifications_enabled', false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Benachrichtigungen in der App blockiert.')),
        );
      }
    }
  }

  /// Öffnet einen Dialog mit Hinweis auf Systemeinstellungen.
  /// Wird verwendet, wenn Benachrichtigungen dauerhaft auf Systemebene deaktiviert wurden.
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Berechtigung erforderlich'),
        content: const Text('Du hast Benachrichtigungen dauerhaft deaktiviert. Bitte aktiviere sie in den Einstellungen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          TextButton(onPressed: () {
            openAppSettings();
            Navigator.pop(context);
          }, child: const Text('Einstellungen')),
        ],
      ),
    );
  }

  /// Startet die Verbindung und Synchronisation mit Fitbit.
  /// Das Ergebnis wird dem Benutzer als SnackBar angezeigt.
  Future<void> _handleFitbitConnection() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verbinde mit Fitbit...')),
    );

    // Call the service (Clean!)
    String resultMessage = await _fitbitService.connectAndSync();

    // Show result
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultMessage),
          backgroundColor: resultMessage.contains("Fehler") ? Colors.red : AppColors.primaryGreen,
        ),
      );
    }
  }

  /// Navigiert zu einem Feature-Screen basierend auf dem Namen.
  /// Wird von den Dashboard-Karten verwendet.
  void _navigateToScreen(String name) {
    switch (name) {
      case 'Symptomtagebuch': Navigator.pushNamed(context, '/symptoms'); break;
      case 'Peak-Flow': Navigator.pushNamed(context, '/peakflow'); break;
      case 'Medikationsplan': Navigator.pushNamed(context, '/medication'); break;
      case 'Warnungen': Navigator.pushNamed(context, '/warnings'); break;
      case 'Notfall': Navigator.pushNamed(context, '/emergency'); break;
      case 'Vitaldaten': Navigator.pushNamed(context, '/vitals'); break;
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: AppColors.backgroundColor, body: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GreetingHeader(userName: _currentUser?.displayName ?? "Gast"),
                    IconButton(icon: const Icon(Icons.logout), color: AppColors.primaryGreen, onPressed: _handleLogout),
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
                  content: 'Pollen & Luftqualität\nAktuelle Werte anzeigen',
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
                  content: 'Puls: 72 bpm\nSauerstoff: 98%\nAtemfrequenz: 14/min',
                  onTap: () => _navigateToScreen('Vitaldaten'),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.notifications_active, color: AppColors.primaryGreen),
                          SizedBox(width: 12),
                          Text('Benachrichtigungen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Switch(
                        value: _notificationsEnabled,
                        onChanged: _toggleNotifications,
                        activeColor: AppColors.primaryGreen,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _handleFitbitConnection,
                    icon: const Icon(Icons.watch),
                    label: const Text("Mit Fitbit verbinden"),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
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
