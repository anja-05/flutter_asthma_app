import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';

/// Login-Screen der App.
/// Dieser Screen ermöglicht bestehenden Benutzer:innen:
/// - die Anmeldung mit E-Mail und Passwort
/// - die Navigation zur Registrierung
///
/// Er übernimmt:
/// - Formularvalidierung
/// - Authentifizierung über [AuthService]
/// - Weiterleitung zum [DashboardScreen] bei Erfolg
class LoginScreen extends StatefulWidget {
  /// Erstellt einen neuen [LoginScreen].
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// Zustandsklasse für den [LoginScreen].
/// Verwaltet:
/// - Eingabefelder (E-Mail, Passwort)
/// - Ladezustand während des Logins
/// - Passwort-Sichtbarkeit
/// - Navigation nach erfolgreicher Anmeldung
class _LoginScreenState extends State<LoginScreen> {
  /// Schlüssel zur Verwaltung und Validierung des Formulars.
  final _formKey = GlobalKey<FormState>();
  /// Controller für das E-Mail-Eingabefeld.
  final _emailController = TextEditingController();
  /// Controller für das Passwort-Eingabefeld.
  final _passwordController = TextEditingController();
  /// Service zur Authentifizierung.
  final _authService = AuthService();
  /// Gibt an, ob gerade ein Login-Vorgang läuft.
  bool _isLoading = false;
  /// Steuert, ob das Passwort verdeckt angezeigt wird.
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Führt den Login-Vorgang aus.
  /// Ablauf:
  /// 1. Formularvalidierung
  /// 2. Authentifizierung über [AuthService]
  /// 3. Navigation zum [DashboardScreen] bei Erfolg
  /// 4. Anzeige einer Fehlermeldung bei Misserfolg
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (user != null) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anmeldung fehlgeschlagen. Bitte überprüfen Sie Ihre Daten.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Navigiert zum [RegisterScreen].
  /// Wird verwendet, wenn noch kein Benutzerkonto existiert.
  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  /// Baut die Benutzeroberfläche des Login-Screens.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.air,
                    size: 50,
                    color: AppColors.primaryGreen,
                  ),
                ),

                const SizedBox(height: 16),

                // App Name
                Text(
                  'AsthmaAssist',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Ihr digitaler Gesundheitsbegleiter',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 48),

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
                          // Titel
                          Text(
                            'Anmelden',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),

                          const SizedBox(height: 24),

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

                          const SizedBox(height: 8),

                          const SizedBox(height: 16),

                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
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
                                    'Anmelden',
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

                Row(
                  children: [
                    Expanded(
                        child: Divider(
                            color: AppColors.textSecondary
                                .withValues(alpha: 0.3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ODER',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                        child: Divider(
                            color: AppColors.textSecondary
                                .withValues(alpha: 0.3))),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  'Noch kein Konto?',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 12),

                OutlinedButton(
                  onPressed: _navigateToRegister,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: BorderSide(
                      color: AppColors.primaryGreen,
                      width: 2,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Registrieren',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  'Mit deiner Anmeldung stimmst du unseren\nDatenschutzrichtlinien zu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
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