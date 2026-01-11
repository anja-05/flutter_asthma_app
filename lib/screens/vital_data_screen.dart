import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../widgets/common/app_card.dart';
import '../widgets/vitals/vital_value_card.dart';
import '../widgets/vitals/vital_chart.dart';

class VitalScreen extends StatefulWidget {
  const VitalScreen({super.key});

  @override
  State<VitalScreen> createState() => _VitalScreenState();
}

class _VitalScreenState extends State<VitalScreen> {
  int selectedTabIndex = 0;

  final List<String> tabs = ['Puls', 'Blutsauerstoff', 'Atemfrequenz'];

  final List<VitalChartData> heartRateData = [
    VitalChartData(time: '17.10', value: 70),
    VitalChartData(time: '18.10', value: 72),
    VitalChartData(time: '19.10', value: 75),
    VitalChartData(time: '20.10', value: 73),
    VitalChartData(time: '21.10', value: 71),
  ];

  final List<VitalEntry> history = [
    VitalEntry(date: '21.10.2025', time: '18:00', pulse: 72, oxygen: 98, breath: 14),
    VitalEntry(date: '21.10.2025', time: '12:00', pulse: 75, oxygen: 98, breath: 14, trendUp: true),
    VitalEntry(date: '20.10.2025', time: '18:00', pulse: 70, oxygen: 97, breath: 15, trendDown: true),
    VitalEntry(date: '20.10.2025', time: '12:00', pulse: 73, oxygen: 98, breath: 14),
  ];

  @override
  Widget build(BuildContext context) {
    final today =  DateFormat('EEEE, dd. MMMM yyyy', 'de_DE').format(DateTime.now());

    return Scaffold(
        backgroundColor: const Color(0xFFF9FCF9),
        body: SafeArea(
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
        Row(
        children: [
        Text(
        today,
        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        ],
        ),
        const SizedBox(height: 24),

          // ✅ Aktuelle Werte
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
                    Text('Verbunden', style: TextStyle(color: Color(0xFF388E3C))),
                  ],
                ),
                const SizedBox(height: 16),
                VitalValueCard(
                  title: 'Puls',
                  value: '72',
                  unit: 'bpm',
                  icon: Icons.favorite_border,
                  color: const Color(0xFFD32F2F),
                ),
                const SizedBox(height: 12),
                VitalValueCard(
                  title: 'Blutsauerstoff',
                  value: '98',
                  unit: '%',
                  icon: Icons.water_drop,
                  color: const Color(0xFF2196F3),
                ),
                const SizedBox(height: 12),
                VitalValueCard(
                  title: 'Atemfrequenz',
                  value: '14',
                  unit: '/min',
                  icon: Icons.air,
                  color: const Color(0xFF388E3C),
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
                    onTap: () {
                      setState(() => selectedTabIndex = index);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        tabs[index],
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF388E3C) : Colors.grey[600],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
            data: heartRateData,
            unit: selectedTabIndex == 0 ? 'bpm' : selectedTabIndex == 1 ? '%' : '/min',
            color: selectedTabIndex == 0
                ? const Color(0xFFD32F2F)
                : selectedTabIndex == 1
                ? const Color(0xFF2196F3)
                : const Color(0xFF388E3C),
            minY: selectedTabIndex == 0 ? 60 : 90,
            maxY: selectedTabIndex == 0 ? 80 : 100,
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
                  'Verlauf / Historie',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF388E3C),
                  ),
                ),
                const SizedBox(height: 16),
                ...history.map((entry) => _buildHistoryTile(entry)).toList(),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Neue Messung erfassen'),
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
        ],
      ),
    ));
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
              Text(entry.date, style: const TextStyle(fontWeight: FontWeight.w600)),
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
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF388E3C)),
        ),
      ],
    );
  }
}

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
