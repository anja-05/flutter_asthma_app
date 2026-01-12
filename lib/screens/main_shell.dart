import 'package:flutter/material.dart';
import '../widgets/common/bottom_navigation.dart';

import 'dashboard_screen.dart';
import 'symptom/symptom_diary_screen.dart';
import 'peak_flow_screen.dart';
import 'medication_plan_screen.dart';

/// Zentrale Shell der App mit Bottom-Navigation.
/// Diese Klasse bildet den strukturellen Rahmen der Anwendung und verwaltet die Navigation zwischen den Hauptbereichen:
/// - Dashboard
/// - Symptomtagebuch
/// - Peak-Flow
/// - Medikationsplan
///
/// Die Navigation erfolgt über eine BottomNavigationBar und wird mit einem [IndexedStack] umgesetzt, um den
/// Zustand der einzelnen Screens beizubehalten.
class MainShell extends StatefulWidget {
  /// Erstellt eine neue [MainShell].
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

/// Zustandsklasse für die [MainShell].
/// Verwaltet:
/// - den aktuell ausgewählten Tab
/// - die zugehörigen Haupt-Screens
/// - die Synchronisation mit der Bottom-Navigation
class _MainShellState extends State<MainShell> {
  /// Index des aktuell ausgewählten Tabs.
  int _currentIndex = 0;

  /// Liste der Haupt-Screens der App.
  /// Die Reihenfolge muss der Reihenfolge der Bottom-Navigation entsprechen.
  ///
  /// Durch die Verwendung eines [IndexedStack] bleiben die Zustände der Screens erhalten (z. B. Scrollposition, Formulareingaben).
  final List<Widget> _screens = const [
    DashboardScreen(),
    SymptomDiaryScreen(),
    PeakFlowScreen(),
    MedicationScreen(),
  ];

  /// Wird aufgerufen, wenn ein Tab in der Bottom-Navigation ausgewählt wird.
  /// Aktualisiert den aktuell sichtbaren Screen.
  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// Baut das Grundlayout der App.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
