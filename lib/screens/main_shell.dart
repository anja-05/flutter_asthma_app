import 'package:flutter/material.dart';
import '../widgets/common/bottom_navigation.dart';

import 'dashboard_screen.dart';
import 'symptom/symptom_diary_screen.dart';
import 'peak_flow_screen.dart';
import 'medication_plan_screen.dart';
import 'vital_data_screen.dart';
import 'warnings_screen.dart';

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

  /// Trigger für Dashboard-Aktualisierung
  int _dashboardRefreshId = 0;

  /// Liste der Haupt-Screens der App.
  // late final List<Widget> _screens; // Removed

 @override
  void initState() {
    super.initState();
  }

  /// Wird aufgerufen, wenn ein Tab in der Bottom-Navigation ausgewählt wird.
  /// Aktualisiert den aktuell sichtbaren Screen.
  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 0) {
        _dashboardRefreshId++;
      }
    });
  }

  /// Baut das Grundlayout der App.
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() {
          _currentIndex = 0;
        });
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            DashboardScreen(
              onSwitchTab: _onTabSelected,
              refreshTrigger: _dashboardRefreshId,
            ),
            const SymptomDiaryScreen(),
            const PeakFlowScreen(),
            const MedicationScreen(),
            const VitalScreen(),
            const WarningScreen(),
          ],
        ),
        bottomNavigationBar: AppBottomNavigation(
          currentIndex: _currentIndex,
          onTap: _onTabSelected,
        ),
      ),
    );
  }
}
