import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../constants/app_colors.dart';
import '../widgets/warnings/aqi_card.dart';
import '../widgets/warnings/pollen_card.dart';
import '../widgets/warnings/warning_banner.dart';
import '../widgets/common/app_card.dart';

/// Screen responsible for displaying environmental warnings.
///
/// Fetches real-time Air Quality Index (AQI) and Pollen data from the
/// Open-Meteo API based on the user's current GPS location.
/// Displays a summary banner, detailed cards, and a 5-day forecast.
class WarningScreen extends StatefulWidget {
  const WarningScreen({super.key});
  @override
  State<WarningScreen> createState() => _WarningScreenState();
}

class _WarningScreenState extends State<WarningScreen> {
  /// Holds the current day's processed data (AQI + Pollen categories).
  Map<String, dynamic>? _current;

  /// Holds the processed daily forecast data for the next 5 days.
  List<dynamic>? _forecast;

  bool _loading = true;
  String? _error;

  /// List of specific pollen API keys requested from Open-Meteo.
  static const _pollenTypes = [
    'birch_pollen', 'grass_pollen', 'olive_pollen',
    'ragweed_pollen', 'alder_pollen', 'mugwort_pollen'
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  /// Helper to safely calculate the maximum value from a list of dynamic values.
  ///
  /// Filters out nulls and converts non-null values to [double] before
  /// finding the maximum. Returns `0.0` if the list is empty or contains only nulls.
  double _getMax(List<dynamic> values) {
    if (values.isEmpty) return 0.0;
    return values.where((e) => e != null).map((e) => (e as num).toDouble()).fold(0.0, max);
  }

  /// Orchestrates the data fetching process.
  ///
  /// 1. Determines user position.
  /// 2. Builds the API URI with query parameters.
  /// 3. Executes the HTTP GET request.
  /// 4. Decodes JSON and processes data into UI-ready formats.
  /// 5. Updates state or sets error message on failure.
  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });

    try {
      final pos = await _determinePos();

      // Constructs the URL for Open-Meteo Air Quality API
      final uri = Uri.https('air-quality-api.open-meteo.com', '/v1/air-quality', {
        'latitude': pos.latitude.toString(),
        'longitude': pos.longitude.toString(),
        'current': 'european_aqi,${_pollenTypes.join(',')}',
        'hourly': 'european_aqi,${_pollenTypes.join(',')}',
        'timezone': 'auto',
        'forecast_days': '7',
      });

      final response = await http.get(uri);
      if (response.statusCode != 200) throw 'API Error: ${response.statusCode}';

      final data = json.decode(response.body);

      if (!mounted) return;
      setState(() {
        _current = _processCurrent(data['current']);
        _forecast = _processForecast(data['hourly']);
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  /// Transforms raw API 'current' data into a structured Map.
  ///
  /// Aggregates specific pollen types into broader categories:
  /// - Tree: Birch, Alder, Olive
  /// - Grass: Grass
  /// - Weed: Ragweed, Mugwort
  Map<String, dynamic> _processCurrent(Map<String, dynamic> c) {
    return {
      'AQI': (c['european_aqi'] as num?)?.toInt() ?? 0,
      'pollen': {
        'tree': _getMax([c['birch_pollen'], c['alder_pollen'], c['olive_pollen']]),
        'grass': _getMax([c['grass_pollen']]),
        'weed': _getMax([c['ragweed_pollen'], c['mugwort_pollen']]),
      }
    };
  }

  /// Transforms raw 'hourly' API data into daily summaries.
  ///
  /// Iterates through the hourly data in 24-hour chunks to find the
  /// maximum AQI and pollen levels for each day.
  ///
  /// [h] - The raw hourly data map from the API.
  List<dynamic> _processForecast(Map<String, dynamic> h) {
    final timeList = h['time'] as List;
    final daily = <dynamic>[];

    // Iterate in steps of 24 to process one day at a time.
    // Skips the first 24 hours (index starts at 24) to focus on future days.
    for (int i = 24; i < timeList.length && daily.length < 5; i += 24) {

      /// Extracts a sublist of data for a specific key (for example 'european_aqi')
      /// for the current 24-hour window.
      List<dynamic> getSlice(String key) {
        final list = h[key] as List?;
        if (list == null) return [];
        final end = min(i + 24, list.length);
        return list.sublist(i, end);
      }

      // Calculate max AQI for the day
      int aqi = _getMax(getSlice('european_aqi')).toInt();

      // Fallback: If forecast AQI is missing (0), use the previous day's or current AQI.
      if (aqi == 0) {
        aqi = daily.isNotEmpty ? daily.last['AQI'] : (_current?['AQI'] ?? 0);
      }

      daily.add({
        'date': DateTime.parse(timeList[i]),
        'AQI': aqi,
        'pollen': {
          'tree': _getMax([...getSlice('birch_pollen'), ...getSlice('alder_pollen'), ...getSlice('olive_pollen')]),
          'grass': _getMax(getSlice('grass_pollen')),
          'weed': _getMax([...getSlice('ragweed_pollen'), ...getSlice('mugwort_pollen')]),
        }
      });
    }
    return daily;
  }

  /// Verifies permissions and returns the current [Position].
  ///
  /// Throws error strings if services are disabled or permissions denied.
  Future<Position> _determinePos() async {
    if (!await Geolocator.isLocationServiceEnabled()) throw 'Standort aus';
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
    if (p == LocationPermission.denied || p == LocationPermission.deniedForever) throw 'Keine Berechtigung';
    return await Geolocator.getCurrentPosition();
  }

  /// Maps a raw pollen count (grains/m³) to a risk level (1-4).
  ///
  /// 1: Low, 2: Medium, 3: High, 4: Very High.
  int _risk(double v) => v < 10 ? 1 : v < 30 ? 2 : v < 100 ? 3 : 4;

  // Colors and texts corresponding to risk levels (0=N/A, 1=Low ... 4=Very High)
  static const _riskColors = [Colors.grey, Color(0xFF4CAF50), Color(0xFFFFC107), Color(0xFFFF9800), Color(0xFFF44336)];
  static const _riskTexts = ['N/A', 'Gering', 'Mittel', 'Hoch', 'Sehr hoch'];

  @override
  Widget build(BuildContext context) {
    final aqi = _current?['AQI'] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchData,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildError()
              : ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: [
              const Text('Warnungen', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
              const SizedBox(height: 8),
              const Text('Hier findest du aktuelle Warnungen zur Luftqualität und Pollenbelastung in deiner Region.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Text(DateFormat('EEEE, d. MMMM', 'de_DE').format(DateTime.now()), style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 24),

              _buildBanner(aqi),

              const SizedBox(height: 16),
              AqiCard(
                aqiValue: aqi,
                category: aqi <= 40 ? 'Gut' : aqi <= 70 ? 'Mäßig' : 'Schlecht',
              ),
              const SizedBox(height: 16),
              PollenCard(pollenLevels: {
                'Bäume': _risk(_current!['pollen']['tree']),
                'Gräser': _risk(_current!['pollen']['grass']),
                'Kräuter': _risk(_current!['pollen']['weed']),
              }),
              const SizedBox(height: 24),
              const Text('5-Tage-Vorhersage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
              const SizedBox(height: 12),
              _buildForecastList(),
            ],
          ),
        ),
      ),
    );
  }

  /// Determines the severity of the banner based on [aqi].
  ///
  /// Returns a [WarningBanner] configured for Info, Warning, or Danger levels.
  Widget _buildBanner(int aqi) {
    if (aqi > 60) {
      final isHigh = aqi > 80;
      return WarningBanner(
        title: isHigh ? 'Hohe Belastung' : 'Mäßige Belastung',
        message: isHigh ? 'Kein Sport im Freien.' : 'Vorsicht bei Empfindlichkeit.',
        severity: isHigh ? WarningSeverity.danger : WarningSeverity.warning,
      );
    }
    return const WarningBanner(title: 'Gute Luft', message: 'Alles okay.', severity: WarningSeverity.info);
  }

  /// Renders the 5-day forecast list.
  ///
  /// If data is missing, returns a simple text message.
  Widget _buildForecastList() {
    if (_forecast == null || _forecast!.isEmpty) return const Text('Keine Daten');

    return AppCard(
      child: Column(
        children: List.generate(_forecast!.length, (i) {
          final f = _forecast![i];
          final maxP = _getMax([f['pollen']['tree'], f['pollen']['grass'], f['pollen']['weed']]);
          final r = _risk(maxP);

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: i < _forecast!.length - 1
                ? BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200)))
                : null,
            child: Row(
              children: [
                SizedBox(
                  width: 85,
                  child: Text(DateFormat('EEE, dd.MM.', 'de_DE').format(f['date']), style: const TextStyle(fontWeight: FontWeight.w500)),
                ),
                const Spacer(),
                _miniIcon(Icons.air, _getAqiColor(f['AQI']), 'AQI ${f['AQI']}'),
                const SizedBox(width: 16),
                _miniIcon(Icons.local_florist, _riskColors[r], _riskTexts[r]),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildError() => Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Fehler: $_error'),
        ElevatedButton(onPressed: _fetchData, child: const Text('Retry'))
      ]));

  /// Helper widget to display a small icon with text next to it.
  Widget _miniIcon(IconData i, Color c, String t) => Row(children: [
    Icon(i, size: 16, color: c),
    const SizedBox(width: 4),
    Text(t, style: TextStyle(fontSize: 12, color: c, fontWeight: FontWeight.bold))
  ]);

  /// Returns a color representing the AQI severity.
  Color _getAqiColor(int v) => v <= 40 ? _riskColors[1] : v <= 70 ? _riskColors[2] : _riskColors[4];
}