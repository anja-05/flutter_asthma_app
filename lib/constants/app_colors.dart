import 'package:flutter/material.dart';

/// Zentrale Farbdefinitionen der App.
/// Diese Klasse enthält alle global verwendeten Farben für Layout, Texte, Statusanzeigen und thematische Karten.
class AppColors {
  /// Primäre Grüntöne der App.
  static const Color primaryGreen = Color(0xFF388E3C);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color mediumGreen = Color(0xFF66BB6A);
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color veryLightGreen = Color(0xFFE8F5E9);

  /// Hintergrundfarben für Screens und Karten.
  /// /// [backgroundColor] wird als globaler Screen-Hintergrund genutzt,
  /// [cardBackground] für weiße Card-Container.
  static const Color backgroundColor = Color(0xFFF6FBF7);
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Statusfarben für kritische Situationen.
  static const Color emergencyRed = Color(0xFFD32F2F);
  static const Color warningYellow = Color(0xFFFBC02D);
  static const Color successGreen = Color(0xFF66BB6A);

  /// Farben für Peak-Flow-Zonen gemäß medizinischer Logik.
  /// - Grün: Normalbereich
  /// - Gelb: Achtung / eingeschränkte Funktion
  /// - Rot: Kritischer Bereich
  static const Color greenZone = Color(0xFF66BB6A);
  static const Color yellowZone = Color(0xFFFBC02D);
  static const Color redZone = Color(0xFFD32F2F);

  /// Standard-Textfarben der App.
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFF9E9E9E);

  /// Akzentfarbe für spezielle UI-Elemente.
  static const Color tealAccent = Color(0xFF26A69A);

  /// Hintergrundfarben für thematische Karten (mit Transparenz).
  /// Die Farben basieren auf dem jeweiligen Themenkontext (geringe Opacity für ruhiges Design).
  static Color symptomCardBg = const Color(0xFF81C784).withOpacity(0.13);
  static Color peakFlowCardBg = const Color(0xFF66BB6A).withOpacity(0.13);
  static Color medicationCardBg = const Color(0xFF388E3C).withOpacity(0.13);
  static Color warningCardBg = const Color(0xFF43A047).withOpacity(0.13);
  static Color emergencyCardBg = const Color(0xFFD32F2F).withOpacity(0.13);
  static Color vitalCardBg = const Color(0xFF26A69A).withOpacity(0.13);
}