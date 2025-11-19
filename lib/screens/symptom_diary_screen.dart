import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/symptom/symptom_category_selector.dart';
import '../widgets/symptom/symptom_intensity_slider.dart';
import '../widgets/symptom/symptom_history_card.dart';
import '../constants//app_colors.dart';
import '../widgets/common/app_card.dart';

class SymptomDiaryScreen extends StatefulWidget {
  const SymptomDiaryScreen({super.key});

  @override
  State<SymptomDiaryScreen> createState() => _SymptomDiaryScreenState();
}

class _SymptomDiaryScreenState extends State<SymptomDiaryScreen> {
  final TextEditingController _symptomController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  SymptomCategory? _selectedCategory;
  String _selectedFrequency = 'Gelegentlich';

  final Map<String, int> _symptomIntensities = {
    'Husten': 2,
    'Atemnot': 3,
  };

  final List<Map<String, dynamic>> _history = [
    {
      'date': '20.10.2025',
      'time': '08:30',
      'symptoms': {'Husten': 3, 'Atemnot': 2},
      'notes': 'Weniger stark als gestern',
      'trigger': null,
    },
    {
      'date': '19.10.2025',
      'time': '07:45',
      'symptoms': {'Atemnot': 5, 'Engegefühl': 4},
      'notes': 'Nach körperlicher Anstrengung',
      'trigger': 'Sport',
    },
    {
      'date': '18.10.2025',
      'time': '06:50',
      'symptoms': {'Husten': 1},
      'notes': 'Morgens beim Aufwachen',
      'trigger': null,
    },
  ];

  final List<String> _frequencies = ['Selten', 'Gelegentlich', 'Häufig'];

  void _saveEntry() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Eintrag gespeichert')),
    );

    // Hier könnte man das in ein Datenmodell speichern
    setState(() {
      _history.insert(0, {
        'date': DateFormat('dd.MM.yyyy').format(DateTime.now()),
        'time': DateFormat('HH:mm').format(DateTime.now()),
        'symptoms': Map.from(_symptomIntensities),
        'notes': _notesController.text,
        'trigger': null,
      });

      _notesController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Symptomtagebuch',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Erfasse deine Symptome und Anfälle, um deinen Verlauf zu beobachten.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    DateFormat('EEEE, dd. MMMM yyyy', 'de_DE')
                        .format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.wb_sunny, color: Colors.orangeAccent, size: 18),
                ],
              ),

              const SizedBox(height: 24),

              // Eingabeformular
              AppCard(
                backgroundColor: AppColors.veryLightGreen,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Symptome',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _symptomController,
                      decoration: InputDecoration(
                        hintText: 'Symptome eingeben (z. B. Husten, Atemnot)',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Häufigkeit',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _frequencies.map((freq) {
                        final selected = _selectedFrequency == freq;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedFrequency = freq;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: selected
                                    ? AppColors.primaryGreen
                                    : Colors.white,
                                foregroundColor: selected
                                    ? Colors.white
                                    : AppColors.primaryGreen,
                                side: BorderSide(
                                  color: AppColors.primaryGreen,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: Text(freq),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Notizen',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Notizen oder zusätzliche Beobachtungen...',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveEntry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Eintrag speichern'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Intensitäten
              const Text(
                'Symptomintensität',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 12),
              ..._symptomIntensities.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SymptomIntensitySlider(
                    symptomName: entry.key,
                    intensity: entry.value,
                    icon: Icons.healing,
                    onChanged: (val) {
                      setState(() {
                        _symptomIntensities[entry.key] = val;
                      });
                    },
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Kategorien
              const Text(
                'Symptom-Kategorie',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 12),
              SymptomCategorySelector(
                selectedCategory: _selectedCategory,
                onCategorySelected: (cat) {
                  setState(() {
                    _selectedCategory = cat;
                  });
                },
              ),

              const SizedBox(height: 32),

              // Verlauf
              const Text(
                'Verlauf der letzten Tage',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 12),
              ..._history.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SymptomHistoryCard(
                    date: entry['date'],
                    time: entry['time'],
                    symptoms: Map<String, int>.from(entry['symptoms']),
                    notes: entry['notes'],
                    trigger: entry['trigger'],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
