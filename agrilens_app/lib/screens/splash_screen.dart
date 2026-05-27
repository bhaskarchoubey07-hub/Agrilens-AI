import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final ThemeMode currentThemeMode;

  const SplashScreen({
    super.key,
    required this.toggleTheme,
    required this.currentThemeMode,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _showLanguageSelector = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Show language selector after a short delay
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showLanguageSelector = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final localizations = Provider.of<AppLocalizations>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1B5E20), Colors.black]
                : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Animated Logo
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.center_focus_strong,
                        size: 80.0,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Text(
                      localizations.translate('app_name'),
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        localizations.translate('tagline'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontStyle: FontStyle.italic,
                          color: isDark ? Colors.white70 : const Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              
              // Reactive Language selector or loading spinner
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _showLanguageSelector
                    ? Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  localizations.translate('select_lang'),
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: const Color(0xFF1B5E20),
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: localizations.locale == 'hi'
                                              ? const Color(0xFF1B5E20)
                                              : Colors.grey[300],
                                          foregroundColor: localizations.locale == 'hi'
                                              ? Colors.white
                                              : Colors.black87,
                                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                                        ),
                                        onPressed: () {
                                          localizations.setLocale('hi');
                                        },
                                        child: const Text('हिन्दी (Hindi)', style: TextStyle(fontSize: 18.0)),
                                      ),
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: localizations.locale == 'en'
                                              ? const Color(0xFF1B5E20)
                                              : Colors.grey[300],
                                          foregroundColor: localizations.locale == 'en'
                                              ? Colors.white
                                              : Colors.black87,
                                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                                        ),
                                        onPressed: () {
                                          localizations.setLocale('en');
                                        },
                                        child: const Text('English', style: TextStyle(fontSize: 18.0)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20.0),
                                ElevatedButton(
                                  onPressed: _navigateToLogin,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(localizations.locale == 'hi' ? 'आगे बढ़ें' : 'Continue'),
                                      const SizedBox(width: 8.0),
                                      const Icon(Icons.arrow_forward, color: Colors.white),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const CircularProgressIndicator(
                        color: Color(0xFF1B5E20),
                      ),
              ),
              const SizedBox(height: 40.0),
            ],
          ),
        ),
      ),
    );
  }
}
