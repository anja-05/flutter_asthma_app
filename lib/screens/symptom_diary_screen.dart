import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/symptom_entry.dart';
import '../widgets/common/screen_header.dart';
import '../widgets/common/app_card.dart';
import '../widgets/symptom/symptom_intensity_slider.dart';
import '../widgets/symptom/symptom_history_card.dart';



class SymptomDiaryScreen extends StatefulWidget {
  const SymptomDiaryScreen({Key? key}) : super(key: key);

  @override
  State<SymptomDiaryScreen> createState() => _SymptomDiaryScreenState();
}

class _SymptomDiaryScreenState extends State<SymptomDiaryScreen> {
  // Symptom Intensitäten
  final Map<String, int> _symptomIntensities = {
    'Husten': 0,
    'Atemnot': 0,
    'Engegefühl': 0,
    'Giemen': 0,
  };

  String _selectedFrequency = 'Gelegentlich';
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _triggerController = TextEditingController();

  // Mock Daten für vorherige Einträge
  late List<SymptomEntry> _entries;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    final now = DateTime.now();
    _entries = [
      SymptomEntry.mock(
        id: '1',
        date: now.subtract(const Duration(days: 1)),
        symptoms: {'Husten': 2, 'Atemnot': 3},
        frequency: 'Gelegentlich',
        notes: 'Weniger stark als gestern',
        trigger: 'Körperliche Anstrengung',
        trend: true,
      ),
      SymptomEntry.mock(
        id: '2',
        date: now.subtract(const Duration(days: 2)),
        symptoms: {'Atemnot': 4, 'Engegefühl': 3},
        frequency: 'Häufig',
        notes: 'Nach körperlicher Anstrengung',
        trigger: 'Sport',
        trend: false,
      ),
      SymptomEntry.mock(
        id: '3',
        date: now.subtract(const Duration(days: 3)),
        symptoms: {'Husten': 1},
        frequency: 'Selten',
        notes: 'Morgens beim Aufwachen',
        trend: true,
      ),
    ];
  }

  void _saveEntry() {
    // Filter nur Symptome mit Intensität > 0
    final activeSymptoms = Map<String, int>.from(_symptomIntensities)
      ..removeWhere((key, value) => value == 0);

    if (activeSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte wähle mindestens ein Symptom aus'),
          backgroundColor: Color(0xFFF44336),
        ),
      );
      return;
    }

    final newEntry = SymptomEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      symptoms: activeSymptoms,
      frequency: _selectedFrequency,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      trigger: _triggerController.text.isEmpty ? null : _triggerController.text,
      trend: true,
    );

    setState(() {
      _entries.insert(0, newEntry);
      // Reset
      _symptomIntensities.updateAll((key, value) => 0);
      _notesController.clear();
      _triggerController.clear();
      _selectedFrequency = 'Gelegentlich';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Eintrag gespeichert'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  List<FlSpot> _getChartData() {
    final last7Days = _entries
        .where((e) => e.date.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .toList()
        .reversed
        .toList();

    return last7Days.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.averageIntensity);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          const ScreenHeader(
            title: 'Symptomtagebuch',
            subtitle: 'Erfasse deine Symptome und beobachte deinen Verlauf',
            icon: Icons.event_note,
            showBackButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Eingabebereich
                  _buildInputSection(),
                  const SizedBox(height: 20),

                  // Verlaufs-Chart
                  _buildChartSection(),
                  const SizedBox(height: 20),

                  // Filter-Header
                  _buildFilterHeader(),
                  const SizedBox(height: 12),

                  // Vergangene Einträge
                  _buildHistorySection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return AppCard(
      backgroundColor: const Color(0xFFE8F5E9),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Neuer Eintrag',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 20),

          // Symptom Slider
          ..._symptomIntensities.keys.map((symptom) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SymptomIntensitySlider(
                symptomName: symptom,
                intensity: _symptomIntensities[symptom]!,
                onChanged: (value) {
                  setState(() {
                    _symptomIntensities[symptom] = value;
                  });
                },
                icon: _getSymptomIcon(symptom),
              ),
            );
          }).toList(),

          const SizedBox(height: 20),

          // Häufigkeit
          const Text(
            'Häufigkeit',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildFrequencyButton('Selten'),
              const SizedBox(width: 8),
              _buildFrequencyButton('Gelegentlich'),
              const SizedBox(width: 8),
              _buildFrequencyButton('Häufig'),
            ],
          ),

          const SizedBox(height: 20),

          // Auslöser
          const Text(
            'Auslöser (optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _triggerController,
            decoration: InputDecoration(
              hintText: 'z.B. Sport, Pollen, Kälte...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Notizen
          const Text(
            'Notizen (optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Zusätzliche Beobachtungen...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Speichern Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Eintrag speichern',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyButton(String frequency) {
    final isSelected = _selectedFrequency == frequency;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedFrequency = frequency;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF4CAF50) : Colors.white,
          foregroundColor: isSelected ? Colors.white : const Color(0xFF4CAF50),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: const Color(0xFF4CAF50),
              width: isSelected ? 0 : 1,
            ),
          ),
          elevation: 0,
        ),
        child: Text(
          frequency,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    final chartData = _getChartData();

    return AppCard(
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verlauf der letzten 7 Tage',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: chartData.isEmpty
                ? const Center(
              child: Text(
                'Noch keine Daten vorhanden',
                style: TextStyle(color: Color(0xFF757575)),
              ),
            )
                : LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < _entries.length) {
                          final entry = _entries.reversed
                              .toList()[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${entry.date.day}.${entry.date.month}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF757575),
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF757575),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
                minX: 0,
                maxX: (chartData.length - 1).toDouble(),
                minY: 0,
                maxY: 5,
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    color: const Color(0xFF4CAF50),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFF4CAF50),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4CAF50).withOpacity(0.3),
                          const Color(0xFF4CAF50).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Vergangene Einträge',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4CAF50),
          ),
        ),
        Row(
          children: [
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4CAF50),
                side: const BorderSide(color: Color(0xFF4CAF50)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text(
                'Letzte Woche',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                color: Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    if (_entries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'Noch keine Einträge vorhanden',
            style: TextStyle(
              color: Color(0xFF757575),
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Column(
      children: _entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SymptomHistoryCard(
            date: entry.formattedDate,
            time: entry.formattedTime,
            symptoms: entry.symptoms,
            notes: entry.notes,
            trigger: entry.trigger,
          ),
        );
      }).toList(),
    );
  }

  IconData _getSymptomIcon(String symptom) {
    switch (symptom.toLowerCase()) {
      case 'husten':
        return Icons.sick;
      case 'atemnot':
        return Icons.air;
      case 'engegefühl':
        return Icons.favorite;
      case 'giemen':
        return Icons.graphic_eq;
      default:
        return Icons.circle;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _triggerController.dispose();
    super.dispose();
  }
}
