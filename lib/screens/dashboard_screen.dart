import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../constants/app_colors.dart';
import '../services/medication_service.dart';
import '../widgets/dashboard/dashboard_card.dart';
import '../widgets/dashboard/greeting_header.dart';

import '../services/auth_service.dart';
import '../services/fitbit_service.dart';
import '../models/user.dart';
import 'login_screen.dart';
import '../../models/medication.dart';

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
  final ValueChanged<int>? onSwitchTab;

  /// Erstellt einen neuen [DashboardScreen].
  const DashboardScreen({super.key, this.onSwitchTab});

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
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
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
    _loadNotificationPreference();
    _loadLastEntryDate();
    _loadTrend();
    _loadMedicationTimes();
    _calculateNextMedicationTime();
    tz.initializeTimeZones();
    _initializeNotifications();
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

  /// Lädt die gespeicherte Benachrichtigungseinstellung.
  /// Die Einstellung wird aus [SharedPreferences] gelesen und im lokalen State gespeichert.
  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
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

  // Initialisiert die Benachrichtigungen
  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Planen der Benachrichtigungen
  void _scheduleNotifications(Medication med) async {
    final location = tz.getLocation('Europe/Berlin');
    final now = tz.TZDateTime.now(location);

    for (int i = 0; i < med.times.length; i++) {
      final timeParts = med.times[i].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Einzigartige ID erstellen (Kombination aus Med-Hash und Zeit-Index)
      final int notificationId = med.id.hashCode + i;

      var scheduledTime = tz.TZDateTime(location, now.year, now.month, now.day, hour, minute);

      if (med.frequencyType == 'weekly' && med.weekdays != null) {
        // Logik für bestimmte Wochentage
        for (int weekday in med.weekdays!) {
          // Flutter nutzt 1=Mo...7=So. Wir müssen ggf. Tage addieren, bis der Wochentag passt
          // Dies erfordert eine etwas komplexere Berechnung der nächsten Ausführung.

          await _flutterLocalNotificationsPlugin.zonedSchedule(
            notificationId + weekday, // Eindeutige ID pro Wochentag
            'Medikament: ${med.name}',
            'Es ist Zeit für deine Dosis: ${med.dosage}',
            scheduledTime, // Hier müsste die Logik für den nächsten passenden Wochentag rein
            _notificationDetails(),
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // WICHTIG
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      } else {
        // Standard: Täglich
        if (scheduledTime.isBefore(now)) {
          scheduledTime = scheduledTime.add(const Duration(days: 1));
        }

        await _flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          'Medikament: ${med.name}',
          'Dosis: ${med.dosage}',
          scheduledTime,
          _notificationDetails(),
          matchDateTimeComponents: DateTimeComponents.time,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

// Hilfsmethode für Details
  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'medication_channel_id',
        'Medikations-Erinnerungen',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  /// Aktiviert oder deaktiviert Benachrichtigungen.
  /// Prüft Systemberechtigungen und speichert die Entscheidung dauerhaft in [SharedPreferences].
  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value) {
      // Überprüfen, ob die Benachrichtigungsberechtigung erteilt wurde
      var status = await Permission.notification.status;

      // Wenn die Berechtigung dauerhaft verweigert wurde
      if (status.isPermanentlyDenied) {
        if (mounted) {
          _showSettingsDialog();
          setState(() => _notificationsEnabled = false);
        }
        await prefs.setBool('notifications_enabled', false);
        return;
      }

      // Berechtigungen anfordern
      status = await Permission.notification.request();

      if (mounted) {
        setState(() {
          _notificationsEnabled = status.isGranted;
        });
        await prefs.setBool('notifications_enabled', status.isGranted);

        if (!mounted) return;
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Benachrichtigungen wurden vom System abgelehnt.')),
          );
        }
      }

      // Wenn Benachrichtigungen erteilt wurden, Erinnerungen planen
      if (_notificationsEnabled) {
        // 1. Lade alle Medikamenten-Objekte (nicht nur die Zeiten)
        final List<Medication> allMedications = await MedicationService().loadMedications();

        // 2. Iteriere über jedes Medikament und plane die Benachrichtigungen
        for (var med in allMedications) {
          _scheduleNotifications(med);
        }
      }else {
        // Wenn Benachrichtigungen deaktiviert werden, alle Benachrichtigungen stornieren
        setState(() {
          _notificationsEnabled = false;
        });
        await prefs.setBool('notifications_enabled', false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Benachrichtigungen in der App blockiert.')),
          );

          // Alle geplanten Benachrichtigungen löschen
          await _flutterLocalNotificationsPlugin.cancelAll();
        }
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
    final routeName = switch (name) {
      'Symptomtagebuch' => '/symptoms',
      'Peak-Flow' => '/peakflow',
      'Medikationsplan' => '/medication',
      'Warnungen' => '/warnings',
      'Notfall' => '/emergency',
      'Vitaldaten' => '/vitals',
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.notifications_active,
                              color: AppColors.primaryGreen,
                            ),
                            const SizedBox(width: 12),
                            const Flexible(
                              child: Text(
                                'Benachrichtigungen',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _notificationsEnabled,
                        onChanged: _toggleNotifications,
                        activeThumbColor: AppColors.primaryGreen,
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
