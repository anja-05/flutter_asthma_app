import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/common/app_card.dart';
import '../widgets/warnings/aqi_card.dart';
import '../widgets/warnings/pollen_card.dart';
import '../widgets/warnings/warning_banner.dart';
import '../widgets/warnings/weather_status_card.dart';

class WarningScreen extends StatelessWidget {
  const WarningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, dd. MMMM yyyy', 'de_DE').format(DateTime(2025, 10, 23));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FCF9),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            // ✅ Header
            const Text(
              'Standortbasierte Warnungen',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF388E3C),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Erhalte aktuelle Informationen zu Pollen und Luftqualität in deiner Umgebung.',
              style: TextStyle(fontSize: 14, color: Color(0xFF616161)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  today,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF616161)),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.wb_sunny, color: Colors.orangeAccent, size: 18),
              ],
            ),
            const SizedBox(height: 24),

            // ✅ Warnung
            const WarningBanner(
              title: 'Mäßige Belastung',
              message: 'Empfindliche Personen sollten vorsichtig sein.',
              severity: WarningSeverity.warning,
            ),

            const SizedBox(height: 16),

            // ✅ AQI Karte
            const AqiCard(
              aqiValue: 42,
              category: 'AQI – Gut',
              location: 'Berlin',
              recommendation: 'Feinstaub niedrig, Ozon normal',
            ),

            const SizedBox(height: 16),

            // ✅ Pollenkarte
            const PollenCard(
              location: 'Berlin',
              pollenLevels: {
                'Gräser': 3,
              },
            ),

            const SizedBox(height: 16),

            // ✅ Verlauf: Chart (Platzhalter)
            AppCard(
              padding: const EdgeInsets.all(16),
              backgroundColor: const Color(0xFFE8F5E9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Luftqualitätsverlauf (6 Tage)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF388E3C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 160,
                    child: Center(
                      child: Image.asset(
                        'assets/images/chart_placeholder.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ✅ Button: Mehr Infos
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.info_outline),
                label: const Text('Mehr Infos & Tipps anzeigen'),
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

            const SizedBox(height: 24),

            // ✅ Tipps-Box
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFDFF5E1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Tipps für heute',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF388E3C),
                    ),
                  ),
                  SizedBox(height: 12),
                  TipItem(text: 'Sportliche Aktivitäten im Freien nur am frühen Morgen'),
                  TipItem(text: 'Fenster geschlossen halten, besonders am Nachmittag'),
                  TipItem(text: 'Notfallmedikation griffbereit haben'),
                  TipItem(text: 'Nach dem Aufenthalt im Freien Haare waschen'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Einfache Hilfe-Komponente
class TipItem extends StatelessWidget {
  final String text;
  const TipItem({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, color: Color(0xFF388E3C), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF37474F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
