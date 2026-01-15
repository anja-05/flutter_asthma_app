import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../widgets/warnings/aqi_card.dart';
import '../widgets/warnings/pollen_card.dart';
import '../widgets/warnings/warning_banner.dart';
import '../widgets/common/app_card.dart';
import '../main.dart';

class WarningScreen extends StatefulWidget {
  const WarningScreen({super.key});
  @override
  State<WarningScreen> createState() => _WarningScreenState();
}

class _WarningScreenState extends State<WarningScreen> {
  Map<String, dynamic>? _current;
  List<dynamic>? _forecast;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _fetchData(); }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final pos = await _determinePos();
      final raw = await http.get(Uri.parse('https://air-quality-api.open-meteo.com/v1/air-quality?latitude=${pos.latitude}&longitude=${pos.longitude}&current=european_aqi,birch_pollen,grass_pollen,olive_pollen,ragweed_pollen,alder_pollen,mugwort_pollen&hourly=european_aqi,birch_pollen,grass_pollen,olive_pollen,ragweed_pollen,alder_pollen,mugwort_pollen&timezone=auto&forecast_days=7'));

      if (raw.statusCode != 200) throw Exception('API Error: ${raw.statusCode}');
      final data = json.decode(raw.body);

      if (!mounted) return;
      setState(() {
        _current = _processCurrent(data['current']);
        _forecast = _processForecast(data['hourly']);
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString().replaceAll('Exception: ', ''); _loading = false; });
    }
  }

  double _d(dynamic v) => (v as num?)?.toDouble() ?? 0.0;

  Map<String, dynamic> _processCurrent(Map<String, dynamic> c) => {
    'AQI': (c['european_aqi'] as num?)?.toInt() ?? 0,
    'pollen': {
      'tree': [c['birch_pollen'], c['alder_pollen'], c['olive_pollen']].map(_d).reduce(max),
      'grass': _d(c['grass_pollen']),
      'weed': [c['ragweed_pollen'], c['mugwort_pollen']].map(_d).reduce(max),
    }
  };

  List<dynamic> _processForecast(Map<String, dynamic> h) {
    final timeList = h['time'] as List;
    final totalHours = timeList.length;

    double chunkMax(int startIdx, List<String> keys) {
      double maxVal = -1.0;
      for (int i = startIdx; i < startIdx + 24 && i < totalHours; i++) {
        for (var k in keys) {
          if (h[k] != null && i < (h[k] as List).length) {
            final val = _d(h[k][i]);
            if (val > maxVal) maxVal = val;
          }
        }
      }
      return maxVal < 0 ? 0.0 : maxVal;
    }

    List<dynamic> daily = [];
    for (int i = 24; i < totalHours && daily.length < 5; i += 24) {
      final aqi = chunkMax(i, ['european_aqi']).toInt();

      int finalAqi = aqi;
      if (aqi == 0 && daily.isNotEmpty) {
        finalAqi = daily.last['AQI'];
      } else if (aqi == 0 && _current != null) {
        finalAqi = _current!['AQI'];
      }

      daily.add({
        'date': DateTime.parse(timeList[i]),
        'AQI': finalAqi,
        'pollen': {
          'tree': chunkMax(i, ['birch_pollen', 'alder_pollen', 'olive_pollen']),
          'grass': chunkMax(i, ['grass_pollen']),
          'weed': chunkMax(i, ['ragweed_pollen', 'mugwort_pollen']),
        }
      });
    }
    return daily;
  }

  Future<Position> _determinePos() async {
    if (!await Geolocator.isLocationServiceEnabled()) throw 'Standort aus';
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
    if (p == LocationPermission.deniedForever || p == LocationPermission.denied) throw 'Keine Berechtigung';
    return await Geolocator.getCurrentPosition();
  }

  int _risk(double v) => v < 10 ? 1 : v < 30 ? 2 : v < 100 ? 3 : 4;

  static const _colors = [Colors.grey, Color(0xFF4CAF50), Color(0xFFFFC107), Color(0xFFFF9800), Color(0xFFF44336)];
  static const _texts = ['N/A', 'Gering', 'Mittel', 'Hoch', 'Sehr hoch'];

  Future<void> _showNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isEnabledInApp = prefs.getBool('notifications_enabled') ?? false;

    if (!isEnabledInApp) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Benachrichtigungen sind in der App blockiert.')));
      return;
    }

    final status = await Permission.notification.status;
    if (!status.isGranted) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Benachrichtigungen sind im System deaktiviert.')));
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'test_channel', 'Test Notifications',
      channelDescription: 'Channel for test notifications',
      importance: Importance.max, priority: Priority.high,
    );
    await flutterLocalNotificationsPlugin.show(
      0, 'Asthma-Warnung Test', 'Dies ist eine Test-Benachrichtigung für deine Luftqualität.',
      const NotificationDetails(android: androidPlatformChannelSpecifics),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today =
    DateFormat('EEEE, dd. MMMM yyyy', 'de_DE').format(DateTime.now());
    final aqi = _current?['AQI'] ?? 0;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboard',
              (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FCF9),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _fetchData,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _buildError()
                : ListView(
              padding:
              const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                const Text(
                  'Warnungen',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hier findest du aktuelle Warnungen zur Luftqualität und Pollenbelastung in deiner Region.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEEE, d. MMMM', 'de_DE')
                      .format(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                if (aqi > 60)
                  WarningBanner(
                    title:
                    aqi > 80 ? 'Hohe Belastung' : 'Mäßige Belastung',
                    message: aqi > 80
                        ? 'Kein Sport im Freien.'
                        : 'Vorsicht bei Empfindlichkeit.',
                    severity: aqi > 80
                        ? WarningSeverity.danger
                        : WarningSeverity.warning,
                  )
                else
                  const WarningBanner(
                    title: 'Gute Luft',
                    message: 'Alles okay.',
                    severity: WarningSeverity.info,
                  ),

                const SizedBox(height: 16),
                AqiCard(
                  aqiValue: aqi,
                  category: aqi <= 40
                      ? 'Gut'
                      : aqi <= 70
                      ? 'Mäßig'
                      : 'Schlecht',
                ),
                const SizedBox(height: 16),

                PollenCard(pollenLevels: {
                  'Bäume':
                  _risk(_current!['pollen']['tree']),
                  'Gräser':
                  _risk(_current!['pollen']['grass']),
                  'Kräuter':
                  _risk(_current!['pollen']['weed']),
                }),

                const SizedBox(height: 24),
                const Text(
                  '5-Tage-Vorhersage',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF388E3C),
                  ),
                ),
                const SizedBox(height: 12),

                if (_forecast == null || _forecast!.isEmpty)
                  const Text('Keine Daten')
                else
                  AppCard(
                    child: Column(
                      children: List.generate(
                        _forecast!.length,
                            (i) {
                          final f = _forecast![i];
                          final maxP = [
                            (f['pollen']['tree'] as num)
                                .toDouble(),
                            (f['pollen']['grass'] as num)
                                .toDouble(),
                            (f['pollen']['weed'] as num)
                                .toDouble()
                          ].reduce(max);

                          final r = _risk(maxP);

                          return Container(
                            padding:
                            const EdgeInsets.all(12),
                            decoration: i <
                                _forecast!.length - 1
                                ? BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors
                                      .grey.shade200,
                                ),
                              ),
                            )
                                : null,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 85,
                                  child: Text(
                                    DateFormat(
                                      'EEE, dd.MM.',
                                      'de_DE',
                                    ).format(f['date']),
                                    style: const TextStyle(
                                      fontWeight:
                                      FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                _miniIcon(
                                  Icons.air,
                                  _getAqiColor(f['AQI']),
                                  'AQI ${f['AQI']}',
                                ),
                                const SizedBox(width: 16),
                                _miniIcon(
                                  Icons.local_florist,
                                  _colors[r],
                                  _texts[r],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _showNotification,
                  icon: const Icon(
                      Icons.notifications_active),
                  label: const Text(
                      'Test-Benachrichtigung senden'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF388E3C),
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(
                        vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Text('Fehler: $_error'), ElevatedButton(onPressed: _fetchData, child: const Text('Retry'))
  ]));

  Widget _miniIcon(IconData i, Color c, String t) => Row(children: [Icon(i, size: 16, color: c), const SizedBox(width: 4), Text(t, style: TextStyle(fontSize: 12, color: c, fontWeight: FontWeight.bold))]);
  Color _getAqiColor(int v) => v <= 40 ? _colors[1] : v <= 70 ? _colors[2] : _colors[4];
}
