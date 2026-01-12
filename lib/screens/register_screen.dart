import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';

/// Registrierungs-Screen der App.
/// Ermöglicht neuen Benutzer:innen:
/// - die Erstellung eines Kontos
/// - Eingabe persönlicher Basisdaten
/// - sichere Passwortvergabe mit Bestätigung
///
/// Die Registrierung erfolgt über den [AuthService].
class RegisterScreen extends StatefulWidget {
  /// Erstellt einen neuen [RegisterScreen].
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

/// Zustandsklasse für den [RegisterScreen].
/// Verwaltet:
/// - Formularzustand und Validierung
/// - Eingabefelder (Name, E-Mail, Passwort)
/// - Passwort-Sichtbarkeit
/// - Ladezustand während der Registrierung
class _RegisterScreenState extends State<RegisterScreen> {
  /// Schlüssel zur Verwaltung und Validierung des Formulars.
  final _formKey = GlobalKey<FormState>();
  /// Controller für den Vornamen.
  final _firstNameController = TextEditingController();
  /// Controller für den Nachnamen.
  final _lastNameController = TextEditingController();
  /// Controller für die E-Mail-Adresse.
  final _emailController = TextEditingController();
  /// Controller für das Passwort.
  final _passwordController = TextEditingController();
  /// Controller für die Passwort-Bestätigung.
  final _confirmPasswordController = TextEditingController();
  /// Service zur Benutzerregistrierung.
  final _authService = AuthService();
  /// Gibt an, ob gerade ein Registrierungsvorgang läuft.
  bool _isLoading = false;
  /// Steuert, ob das Passwort verdeckt angezeigt wird.
  bool _obscurePassword = true;
  /// Steuert, ob das Bestätigungs-Passwort verdeckt angezeigt wird.
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    // Gibt alle verwendeten TextEditingController frei.
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Führt den Registrierungsvorgang aus.
  /// Ablauf:
  /// 1. Formularvalidierung
  /// 2. Registrierung über [AuthService]
  /// 3. Erfolgsmeldung und Rückkehr zum Login-Screen
  /// 4. Fehlermeldung bei nicht erfolgreicher Registrierung
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await _authService.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrierung erfolgreich! Bitte melden Sie sich an.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrierung fehlgeschlagen. Email bereits vorhanden?'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Baut die Benutzeroberfläche des Registrierungs-Screens.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_add,
                    size: 40,
                    color: AppColors.primaryGreen,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Konto erstellen',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Willkommen bei AsthmaAssist',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 32),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              labelText: 'Vorname',
                              hintText: 'Vorname eingeben',
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: AppColors.primaryGreen,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.veryLightGreen,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.veryLightGreen,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.primaryGreen,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Bitte Vorname eingeben';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: 'Nachname',
                              hintText: 'Nachname eingeben',
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: AppColors.primaryGreen,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.veryLightGreen,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.veryLightGreen,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.primaryGreen,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Bitte Nachname eingeben';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'E-Mail-Adresse',
                              hintText: 'E-Mail eingeben',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppColors.primaryGreen,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.veryLightGreen,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.veryLightGreen,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.primaryGreen,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Bitte E-Mail eingeben';
                              }
                              if (!value.contains('@')) {
                                return 'Ungültige E-Mail-Adresse';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Passwort',
                              hintText: 'Passwort eingeben',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: AppColors.primaryGreen,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.veryLightGreen,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.veryLightGreen,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.primaryGreen,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Bitte Passwort eingeben';
                              }
                              if (value.length < 6) {
                                return 'Passwort muss mindestens 6 Zeichen haben';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Passwort bestätigen',
                              hintText: 'Passwort erneut eingeben',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: AppColors.primaryGreen,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.veryLightGreen,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.veryLightGreen,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.primaryGreen,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Bitte Passwort bestätigen';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwörter stimmen nicht überein';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              'Konto erstellen',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Mit der Registrierung stimmst du unseren\nDatenschutzrichtlinien zu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}