import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_colors.dart';
import 'symptom_entry_tab.dart';
import 'symptom_history_tab.dart';

class SymptomDiaryScreen extends StatefulWidget {
  const SymptomDiaryScreen({super.key});

  @override
  State<SymptomDiaryScreen> createState() => _SymptomDiaryScreenState();
}

class _SymptomDiaryScreenState extends State<SymptomDiaryScreen> {
  final List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void addEntry(Map<String, dynamic> entry) {
    setState(() {
      _history.insert(0, entry);
    });
    _persistHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('symptom_history');

    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      setState(() {
        _history
          ..clear()
          ..addAll(decoded.cast<Map<String, dynamic>>());
      });
    }
  }

  Future<void> _persistHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('symptom_history', jsonEncode(_history));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // HEADER (wie im Screenshot)
              // =========================
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Symptomtagebuch',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Verfolge deine Lungenfunktion und erkenne Veränderungen frühzeitig.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          DateFormat(
                            'EEEE, d. MMMM yyyy',
                            'de_DE',
                          ).format(DateTime.now()),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.wb_sunny,
                          size: 18,
                          color: Colors.orangeAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // =========================
              // TABS
              // =========================
              const TabBar(
                labelColor: Colors.black,
                indicatorColor: AppColors.primaryGreen,
                tabs: [
                  Tab(text: 'Eintrag'),
                  Tab(text: 'Verlauf'),
                ],
              ),

              // =========================
              // TAB CONTENT
              // =========================
              Expanded(
                child: TabBarView(
                  children: [
                    SymptomEntryTab(onSave: addEntry),
                    SymptomHistoryTab(history: _history),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
