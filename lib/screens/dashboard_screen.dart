import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../services/medication_service.dart';
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
/// - Fitbit-Verbindung
class DashboardScreen extends StatefulWidget {
  final ValueChanged<int>? onSwitchTab;
  final int? refreshTrigger;

  /// Erstellt einen neuen [DashboardScreen].
  const DashboardScreen({super.key, this.onSwitchTab, this.refreshTrigger});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

/// Zustandsklasse für den [DashboardScreen].
/// Enthält Logik für:
/// - Laden des aktuellen Benutzers
/// - Verwaltung von App-Einstellungen
/// - Navigation zu Unterseiten
class _DashboardScreenState extends State<DashboardScreen> {
  /// Service zur Authentifizierung und Benutzerverwaltung.
  final _authService = AuthService();
  /// Service zur Verbindung und Synchronisation mit Fitbit.
  final _fitbitService = FitbitService();
  /// Aktuell eingeloggter Benutzer.
  AppUser? _currentUser;
  /// Gibt an, ob Daten noch geladen werden.
  bool _isLoading = true;
  /// Letzter Eintrag eines Symtopms
  String _lastEntryDate = 'Kein Eintrag';
  /// Trend der Symtopme
  String _trend = 'Kein Trend';
  List<String> _medicationTimes = [];
  String _nextMedicationTime = '';

  @override
  void initState() {
    super.initState();
    /// Initialisiert deutsche Datumsformate (z. B. für Begrüßung).
    initializeDateFormatting('de_DE', null);
    _loadUser();
    _loadLastEntryDate();
    _loadTrend();
    _loadMedicationTimes();
    _calculateNextMedicationTime();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshTrigger != oldWidget.refreshTrigger) {
      _loadLastEntryDate();
      _loadTrend();
      _loadMedicationTimes();
      _calculateNextMedicationTime();
    }
  }

  Future<void> _loadMedicationTimes() async {
    final medicationService = MedicationService();
    final times = await medicationService.loadMedicationTimes();
    if (!mounted) return;
    setState(() {
      _medicationTimes = times;
    });
  }

  void _calculateNextMedicationTime() {
    DateTime nextTime = _getNextMedicationTime(_medicationTimes);
    setState(() {
      _nextMedicationTime = DateFormat('HH:mm').format(nextTime);  // Zeigt die nächste Zeit im Format "HH:mm"
    });
  }

  /// Lädt das Datum des letzten Eintrags
  Future<void> _loadLastEntryDate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastEntryDate = prefs.getString('last_entry_date') ?? 'Kein Eintrag';
    if (!mounted) return;
    setState(() {
      _lastEntryDate = lastEntryDate;
    });
  }

  /// Lädt den Trend der Symptome
  Future<void> _loadTrend() async {
    final prefs = await SharedPreferences.getInstance();
    final trend = prefs.getString('trend') ?? 'Kein Trend';
    setState(() {
      _trend = trend;
    });
  }

  /// Lädt den aktuell angemeldeten Benutzer.
  /// Wird beim Initialisieren des Dashboards aufgerufen.
  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    if (!mounted) return;
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
    // Mapping für Tabs in MainShell
    final tabIndex = switch (name) {
      'Symptomtagebuch' => 1,
      'Peak-Flow' => 2,
      'Medikationsplan' => 3,
      'Vitaldaten' => 4,
      'Warnungen' => 5,
      _ => null,
    };

    if (tabIndex != null) {
      widget.onSwitchTab?.call(tabIndex);
      return;
    }

    // Mapping für externe Routen (die BottomBar verdecken sollen)
    final routeName = switch (name) {
      'Notfall' => '/emergency', // Soll explizit ohne BottomBar sein
      _ => null,
    };

    if (routeName != null) {
      Navigator.pushNamed(context, routeName);
    }
  }

  DateTime _getNextMedicationTime(List<String> times) {
    final now = DateTime.now();
    DateTime nextTime = DateTime(now.year, now.month, now.day, 23, 59); // Setzt Standardzeit auf spät abends

    for (var time in times) {
      final parts = time.split(':');
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;

      final timeOfDay = DateTime(now.year, now.month, now.day, hour, minute);

      if (timeOfDay.isAfter(now) && timeOfDay.isBefore(nextTime)) {
        nextTime = timeOfDay;
      }
    }

    if (nextTime.isBefore(now)) {
      nextTime = DateTime(now.year, now.month, now.day + 1, 0, 0);  // Wenn keine zukünftige Zeit gefunden wurde, setze die Zeit auf den nächsten Tag
    }

    return nextTime;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
      );
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
                    Expanded(
                      child: GreetingHeader(userName: _currentUser?.displayName ?? "Gast"),
                    ),
                    IconButton(icon: const Icon(Icons.logout), color: AppColors.primaryGreen, onPressed: _handleLogout),
                  ],
                ),
                const SizedBox(height: 24),
                DashboardCard(
                  title: 'Symptomtagebuch',
                  icon: Icons.book,
                  iconColor: AppColors.lightGreen,
                  backgroundColor: AppColors.symptomCardBg,
                  content: 'Letzter Eintrag: $_lastEntryDate\nTrend: Weniger Anfälle',
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
                  content: 'Nächstes Medikament: $_nextMedicationTime\nKeine Doppeldosierung',
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
