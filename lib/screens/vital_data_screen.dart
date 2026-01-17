import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

import '../constants/app_colors.dart';
import '../widgets/vitals/vital_value_card.dart';
import '../widgets/vitals/vital_chart.dart';
import '../services/fhir_vital_service.dart';

/// Der Hauptbildschirm zur Anzeige und Verwaltung von Vitaldaten.
///
/// Dieser Screen visualisiert Herzfrequenz, Sauerstoffsättigung (SpO2) und Atemfrequenz.
/// Er implementiert eine "Offline-First"-Strategie mithilfe von [SharedPreferences],
/// um Daten sofort anzuzeigen, während im Hintergrund aktuelle Werte vom FHIR-Server geladen werden.
class VitalScreen extends StatefulWidget {
  const VitalScreen({super.key});

  @override
  State<VitalScreen> createState() => _VitalScreenState();
}

class _VitalScreenState extends State<VitalScreen> {
  /// Service zur Kommunikation mit dem Hapi FHIR Server.
  final FhirVitalService _fhirService = FhirVitalService();

  int selectedTabIndex = 0;

  // Platzhalter-Werte, die sofort durch den Cache überschrieben werden.
  String _currentPulse = "--";
  String _currentO2 = "--";
  String _currentBreath = "--";

  List<VitalChartData> _chartData = [];

  final List<String> tabs = ['Puls', 'Blutsauerstoff', 'Atemfrequenz'];

  // Statische Mock-Daten für die Historien-Liste (wegen Implementierungsproblemen nicht dynamisch geladen).
  final List<VitalEntry> history = [
    VitalEntry(
        date: '21.10.2025', time: '18:00', pulse: 72, oxygen: 98, breath: 14),
    VitalEntry(
        date: '21.10.2025',
        time: '12:00',
        pulse: 75,
        oxygen: 98,
        breath: 14,
        trendUp: true),
    VitalEntry(
        date: '20.10.2025',
        time: '18:00',
        pulse: 70,
        oxygen: 97,
        breath: 15,
        trendDown: true),
    VitalEntry(
        date: '20.10.2025', time: '12:00', pulse: 73, oxygen: 98, breath: 14),
  ];

  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  /// Startet den Ladevorgang beim Initialisieren des Screens.
  ///
  /// Strategie:
  /// 1. Lädt sofort lokale Daten aus dem Cache ([_loadFromCache]).
  /// 2. Startet asynchron den Netzwerk-Abruf ([_fetchAndSaveNetworkData]).
  Future<void> _initialLoad() async {
    await _loadFromCache();
    _fetchAndSaveNetworkData();
  }

  /// Lädt die zuletzt bekannten Vitalwerte aus den [SharedPreferences].
  ///
  /// Dies verhindert Ladebalken beim Start und sorgt für eine flüssige User Experience.
  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentPulse = prefs.getString('cache_pulse') ?? "--";
        _currentO2 = prefs.getString('cache_o2') ?? "--";
        _currentBreath = prefs.getString('cache_breath') ?? "--";
      });
    }
  }

  /// Speichert die aktuellen Vitalwerte lokal auf dem Gerät.
  ///
  /// [pulse] - Aktuelle Herzfrequenz.
  /// [o2] - Aktuelle Sauerstoffsättigung.
  /// [breath] - Aktuelle Atemfrequenz.
  Future<void> _updateCache(String pulse, String o2, String breath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cache_pulse', pulse);
    await prefs.setString('cache_o2', o2);
    await prefs.setString('cache_breath', breath);
  }

  /// Ruft aktuelle Daten und Verlaufsdaten vom FHIR-Server ab.
  ///
  /// Führt folgende Schritte aus:
  /// 1. Paralleler Abruf der neuesten Werte für Puls, O2 und Atmung.
  /// 2. Aktualisierung des lokalen Caches.
  /// 3. Abruf der Historie für das Diagramm basierend auf dem gewählten Tab.
  Future<void> _fetchAndSaveNetworkData() async {
    try {
      // 1. Aktuelle Werte parallel abrufen (Performance)
      final results = await Future.wait([
        _fhirService.getLatestVital(FhirVitalService.codeHeartRate),
        _fhirService.getLatestVital(FhirVitalService.codeOxygen),
        _fhirService.getLatestVital(FhirVitalService.codeRespiratoryRate),
      ]);

      // 2. Cache aktualisieren
      await _updateCache(results[0], results[1], results[2]);

      // 3. Daten für Diagram für jeweiligen Tab laden
      String codeForChart;
      if (selectedTabIndex == 0) {
        codeForChart = FhirVitalService.codeHeartRate;
      } else if (selectedTabIndex == 1) {
        codeForChart = FhirVitalService.codeOxygen;
      } else {
        codeForChart = FhirVitalService.codeRespiratoryRate;
      }

      final historyRaw = await _fhirService.getVitalHistory(codeForChart);

      // Mapping der Server-Daten auf das Chart-Format
      final List<VitalChartData> newChartData = historyRaw.map((item) {
        final date = item['time'] as DateTime;
        final val = item['value'] as double;
        return VitalChartData(
            time: DateFormat('HH:mm').format(date), value: val);
      }).toList();

      if (newChartData.isEmpty) {
        newChartData.add(VitalChartData(time: "--", value: 0));
      }

      if (mounted) {
        setState(() {
          _currentPulse = results[0];
          _currentO2 = results[1];
          _currentBreath = results[2];
          _chartData = newChartData.reversed.toList();
        });
      }
    } catch (e) {
      debugPrint("Fehler beim Laden der Vitaldaten: $e");
      if (mounted) {}
    }
  }

  /// Wird aufgerufen, wenn der Benutzer den Tab (Puls/O2/Atmung) wechselt.
  /// Lädt die Diagramm-Daten für die neu ausgewählte Kategorie nach.
  void _onTabChanged(int index) {
    setState(() {
      selectedTabIndex = index;
    });
    _fetchAndSaveNetworkData();
  }

  /// Generiert zufällige Vitalwerte und sendet sie an den FHIR-Server.
  ///
  /// Dient zu Demonstrationszwecken, um die Funktionalität ohne physisches
  /// Fitbit-Gerät zu zeigen.
  Future<void> _addManualMeasurement() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Speichere generierte Demo-Messung...')),
    );

    try {
      final random = Random();
      double fakePulse = 60 + random.nextInt(40).toDouble(); // 60-100 bpm
      double fakeO2 = 95 + random.nextInt(4).toDouble(); // 95-99 %
      double fakeBreath = 12 + random.nextInt(8).toDouble(); // 12-20 rpm

      // Sende an Server
      await _fhirService.saveVital(
          code: FhirVitalService.codeHeartRate,
          display: "Heart Rate",
          value: fakePulse,
          unit: "bpm");

      await _fhirService.saveVital(
          code: FhirVitalService.codeOxygen,
          display: "Oxygen Saturation",
          value: fakeO2,
          unit: "%");

      await _fhirService.saveVital(
          code: FhirVitalService.codeRespiratoryRate,
          display: "Respiratory Rate",
          value: fakeBreath,
          unit: "/min");

      // Aktualisiere die UI
      await _fetchAndSaveNetworkData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Demo-Werte gespeichert: ${fakePulse.toInt()} bpm')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final today =
        DateFormat('EEEE, dd. MMMM yyyy', 'de_DE').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FCF9),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchAndSaveNetworkData,
          color: const Color(0xFF388E3C),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              const Text(
                'Vitaldaten',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Erfasse oder synchronisiere deine Vitalwerte und behalte deinen Verlauf im Blick.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                today,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Aktuelle Werte
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text(
                          'Aktuelle Werte',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF388E3C),
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.bluetooth, color: Color(0xFF388E3C)),
                        SizedBox(width: 4),
                        Text('Verbunden',
                            style: TextStyle(color: Color(0xFF388E3C))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    VitalValueCard(
                      title: 'Puls',
                      value: _currentPulse,
                      unit: 'bpm',
                      icon: Icons.favorite_border,
                      color: const Color(0xFFD32F2F),
                    ),
                    const SizedBox(height: 12),
                    VitalValueCard(
                      title: 'Blutsauerstoff',
                      value: _currentO2,
                      unit: '%',
                      icon: Icons.water_drop,
                      color: const Color(0xFF2196F3),
                    ),
                    const SizedBox(height: 12),
                    VitalValueCard(
                      title: 'Atemfrequenz',
                      value: _currentBreath,
                      unit: '/min',
                      icon: Icons.air,
                      color: const Color(0xFF388E3C),
                    ),
                  ],
                ),
              ),

              // Hinweis-Box
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade800),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Hinweis: Sauerstoffsättigung und Atemfrequenz werden von Fitbit nur während des Schlafs gemessen. Werte sind Durchschnittswerte.",
                        style: TextStyle(
                            color: Colors.amber.shade900, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Verlauf',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF388E3C),
                ),
              ),
              const SizedBox(height: 12),

              // Tab-Auswahl
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: List.generate(tabs.length, (index) {
                    final isSelected = selectedTabIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onTabChanged(index),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            tabs[index],
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF388E3C)
                                  : Colors.grey[600],
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 16),

              VitalChart(
                title: tabs[selectedTabIndex],
                data: _chartData,
                unit: selectedTabIndex == 0
                    ? 'bpm'
                    : selectedTabIndex == 1
                        ? '%'
                        : '/min',
                color: selectedTabIndex == 0
                    ? const Color(0xFFD32F2F)
                    : selectedTabIndex == 1
                        ? const Color(0xFF2196F3)
                        : const Color(0xFF388E3C),
                minY: selectedTabIndex == 0
                    ? 40
                    : selectedTabIndex == 1
                        ? 80
                        : 0,
                maxY: selectedTabIndex == 0
                    ? 100
                    : selectedTabIndex == 1
                        ? 100
                        : 40,
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Verlauf / Historie (Demo)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF388E3C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...history
                        .map((entry) => _buildHistoryTile(entry))
                        .toList(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addManualMeasurement,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Manuelle Messung (nur für Demo)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF388E3C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTile(VitalEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.date,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(entry.time, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const Spacer(),
          _buildVitalMini('Puls', '${entry.pulse} bpm'),
          const SizedBox(width: 12),
          _buildVitalMini('O₂', '${entry.oxygen}%'),
          const SizedBox(width: 12),
          _buildVitalMini('Atmung', '${entry.breath}/min'),
          if (entry.trendUp)
            const Icon(Icons.trending_up, color: Color(0xFF388E3C))
          else if (entry.trendDown)
            const Icon(Icons.trending_down, color: Color(0xFFE53935)),
        ],
      ),
    );
  }

  Widget _buildVitalMini(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF388E3C)),
        ),
      ],
    );
  }
}

/// Datenmodell für einen einzelnen Eintrag in der Vitalwert-Historie.
class VitalEntry {
  final String date;
  final String time;
  final int pulse;
  final int oxygen;
  final int breath;
  final bool trendUp;
  final bool trendDown;

  VitalEntry({
    required this.date,
    required this.time,
    required this.pulse,
    required this.oxygen,
    required this.breath,
    this.trendUp = false,
    this.trendDown = false,
  });
}
