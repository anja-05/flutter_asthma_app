import 'package:fitbitter/fitbitter.dart';
import 'package:flutter/foundation.dart'; // For debugprint
import 'fhir_vital_service.dart';

/// Service zur Verwaltung der Fitbit-Integration.
///
/// Diese Klasse kümmert sich um die OAuth 2.0 Authentifizierung gegenüber der Fitbit Web-API,
/// das Abrufen von Rohdaten (Puls, SpO2, Atemfrequenz) und die Weiterleitung dieser Daten
/// an den [FhirVitalService] zur Speicherung.
class FitbitService {
  // --- API Credentials ---

  /// Die Client-ID der registrierten Fitbit-App.
  static const String _clientId = '23TQ8M';

  /// Das Client-Secret der Fitbit-App.
  static const String _clientSecret = 'b6c85177c8b0c82babec097bc6c47141';

  // Interne Abhängigkeit zum Speichern der Daten auf dem FHIR-Server
  final FhirVitalService _fhirService = FhirVitalService();

  /// Hauptmethode zum Verbinden und Synchronisieren aller Vitaldaten.
  ///
  /// Führt folgende Schritte aus:
  /// 1. Öffnet ein Browser-Fenster zur Fitbit-Anmeldung (OAuth 2.0).
  /// 2. Wartet auf die Bestätigung und das Token.
  /// 3. Startet parallel den Abruf von Herzfrequenz, SpO2 und Atemfrequenz.
  /// 4. Speichert validierte Daten über den [FhirVitalService].
  ///
  /// Rückgabe:
  /// Ein [String] mit einer Statusmeldung für den Benutzer (z.B. "3/3 Werte gespeichert").
  Future<String> connectAndSync() async {
    try {
      // Autorisierung via Fitbitter Plugin (öffnet Webview/Browser)
      FitbitCredentials? credentials = await FitbitConnector.authorize(
        clientID: _clientId,
        clientSecret: _clientSecret,
        redirectUri: 'asthmaassist://fitbit-auth',
        callbackUrlScheme: 'asthmaassist',
      );

      if (credentials == null) {
        return "Login abgebrochen.";
      }

      // Paralleler Abruf aller Datentypen (Performance-Optimierung)
      final results = await Future.wait([
        _syncHeartRate(credentials),
        _syncSpO2(credentials),
        _syncBreathingRate(credentials),
      ]);

      // // Zählen, wie viele Synchronisationen erfolgreich sind (true zurückgeben)
      final successCount = results.where((r) => r == true).length;
      return "Synchronisation fertig: $successCount/3 Werte gespeichert.";

    } catch (e) {
      debugPrint("Fitbit Error: $e");
      return "Fehler bei der Verbindung: $e";
    }
  }

  /// ---------------------------------------------------
  /// PRIVATE HELPER METHODEN
  /// ---------------------------------------------------

  /// Synchronisiert die Herzfrequenz-Daten (Intraday).
  ///
  /// Ruft die minutengenauen Daten des heutigen Tages ab und nimmt den
  /// zeitlich letzten Wert als "aktuellen" Puls.
  Future<bool> _syncHeartRate(FitbitCredentials creds) async {
    try {
      final manager = FitbitHeartRateIntradayDataManager(
        clientID: _clientId,
        clientSecret: _clientSecret,
      );

      // Abruf der Intraday-Daten (1-Minuten-Intervalle) für Heute
      final url = FitbitHeartRateIntradayAPIURL.dayAndDetailLevel(
        date: DateTime.now(),
        intradayDetailLevel: IntradayDetailLevel.ONE_MINUTE,
        fitbitCredentials: creds,
      );

      final data = await manager.fetch(url);

      if (data.isNotEmpty) {
        // Den allerletzten (aktuellsten) Eintrag extrahieren
        final latest = data.last as FitbitHeartRateIntradayData;
        final value = latest.value?.toDouble() ?? 0.0;

        // An FHIR-Service senden
        await _fhirService.saveVital(
            code: FhirVitalService.codeHeartRate,
            display: "Heart Rate",
            value: value,
            unit: "bpm"
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Heart Rate Sync Error: $e");
      return false;
    }
  }

  /// Synchronisiert die Sauerstoffsättigung (SpO2).
  ///
  /// Hinweis: SpO2 wird von Fitbit nur während des Schlafs gemessen.
  /// Der abgerufene Wert ist daher der Durchschnittswert der letzten Nacht.
  Future<bool> _syncSpO2(FitbitCredentials creds) async {
    try {
      final manager = FitbitSpO2DataManager(
        clientID: _clientId,
        clientSecret: _clientSecret,
      );

      final url = FitbitSpO2APIURL.day(
        date: DateTime.now(),
        fitbitCredentials: creds,
      );

      final data = await manager.fetch(url);

      if (data.isNotEmpty) {
        final latest = data.last as FitbitSpO2Data;
        // Je nach API-Version wird der Wert in 'value' oder 'avgValue' gespeichert
        final value = latest.avgValue ?? 0.0;

        await _fhirService.saveVital(
            code: FhirVitalService.codeOxygen,
            display: "Oxygen Saturation",
            value: value,
            unit: "%"
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("SpO2 Sync Error: $e");
      return false;
    }
  }

  /// Synchronisiert die Atemfrequenz (Breathing Rate).
  ///
  /// Hinweis: Wie SpO2 ist dies ein Parameter, der primär während des Schlafs
  /// erfasst wird.
  Future<bool> _syncBreathingRate(FitbitCredentials creds) async {
    try {
      final manager = FitbitBreathingRateDataManager(
        clientID: _clientId,
        clientSecret: _clientSecret,
      );

      final url = FitbitBreathingRateAPIURL.day(
        date: DateTime.now(),
        fitbitCredentials: creds,
      );

      final data = await manager.fetch(url);

      if (data.isNotEmpty) {
        final latest = data.last as FitbitBreathingRateData;
        final value = latest.value ?? 0.0;

        await _fhirService.saveVital(
            code: FhirVitalService.codeRespiratoryRate,
            display: "Respiratory Rate",
            value: value,
            unit: "/min"
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Breathing Sync Error: $e");
      return false;
    }
  }
}