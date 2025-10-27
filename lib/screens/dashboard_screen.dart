import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../constants/app_colors.dart';
import '../widgets/dashboard/dashboard_card.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

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

  String _getCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, d. MMMM yyyy', 'de_DE');
    return formatter.format(now);
  }

  void _navigateToScreen(String screenName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigation zu: $screenName'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abmelden'),
        content: const Text('Möchten Sie sich wirklich abmelden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Abmelden'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryGreen,
          ),
        ),
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
                // Header mit Logout Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Begrüßung mit dynamischem Namen
                          Text(
                            'Hallo, ${_currentUser?.displayName ?? "Gast"}!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Datum mit Emoji
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _getCurrentDate(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF757575),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                '☀️',
                                style: TextStyle(fontSize: 24),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Logout Button
                    IconButton(
                      icon: const Icon(Icons.logout),
                      color: AppColors.primaryGreen,
                      onPressed: _handleLogout,
                      tooltip: 'Abmelden',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Info Cards
                DashboardCard(
                  title: 'Symptomtagebuch',
                  icon: Icons.book,
                  iconColor: const Color(0xFF81C784),
                  backgroundColor: AppColors.symptomCardBg,
                  content: 'Letzter Eintrag: 20.10.2025\nTrend: Weniger Anfälle',
                  onTap: () => _navigateToScreen('Symptomtagebuch'),
                ),

                const SizedBox(height: 16),

                DashboardCard(
                  title: 'Peak-Flow',
                  icon: Icons.show_chart,
                  iconColor: const Color(0xFF66BB6A),
                  backgroundColor: AppColors.peakFlowCardBg,
                  content: 'Letzte Messung: 350 l/min\nIm grünen Bereich',
                  onTap: () => _navigateToScreen('Peak-Flow'),
                ),

                const SizedBox(height: 16),

                DashboardCard(
                  title: 'Medikationsplan',
                  icon: Icons.medication,
                  iconColor: const Color(0xFF388E3C),
                  backgroundColor: AppColors.medicationCardBg,
                  content: 'Nächstes Medikament: 18:00 Uhr\nKeine Doppeldosierung',
                  onTap: () => _navigateToScreen('Medikationsplan'),
                ),

                const SizedBox(height: 16),

                DashboardCard(
                  title: 'Warnungen',
                  icon: Icons.warning_amber,
                  iconColor: const Color(0xFF43A047),
                  backgroundColor: AppColors.warningCardBg,
                  content: 'Pollen: Hoch\nLuftqualität: Gut',
                  onTap: () => _navigateToScreen('Warnungen'),
                ),

                const SizedBox(height: 16),

                DashboardCard(
                  title: 'Notfall',
                  icon: Icons.phone,
                  iconColor: const Color(0xFFD32F2F),
                  backgroundColor: AppColors.emergencyCardBg,
                  content: 'Notfallplan bereit\nSOS-Button verfügbar',
                  onTap: () => _navigateToScreen('Notfall'),
                ),

                const SizedBox(height: 16),

                DashboardCard(
                  title: 'Vitaldaten',
                  icon: Icons.favorite,
                  iconColor: const Color(0xFF26A69A),
                  backgroundColor: AppColors.vitalCardBg,
                  content: 'Puls: 72 bpm\nSauerstoff: 98%\nAtemfrequenz: 14/min',
                  onTap: () => _navigateToScreen('Vitaldaten'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}