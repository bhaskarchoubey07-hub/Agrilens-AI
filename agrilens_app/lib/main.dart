import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'services/voice_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/crop_scanner_screen.dart';
import 'screens/weather_screen.dart';
import 'screens/soil_health_screen.dart';
import 'screens/voice_assistant_screen.dart';
import 'screens/disease_heatmap_screen.dart';
import 'screens/market_prices_screen.dart';
import 'screens/gov_schemes_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/finance_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppLocalizations()),
        ChangeNotifierProvider(create: (_) => VoiceService()),
      ],
      child: const AgriLensApp(),
    ),
  );
}

class AgriLensApp extends StatefulWidget {
  const AgriLensApp({super.key});

  @override
  State<AgriLensApp> createState() => _AgriLensAppState();
}

class _AgriLensAppState extends State<AgriLensApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriLens AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: SplashScreen(toggleTheme: toggleTheme, currentThemeMode: _themeMode),
      routes: {
        '/login': (context) => LoginScreen(toggleTheme: toggleTheme, currentThemeMode: _themeMode),
        '/home': (context) => HomeDashboard(toggleTheme: toggleTheme, currentThemeMode: _themeMode),
        '/scan': (context) => const CropScannerScreen(),
        '/weather': (context) => const WeatherScreen(),
        '/soil': (context) => const SoilHealthScreen(),
        '/voice': (context) => const VoiceAssistantScreen(),
        '/heatmap': (context) => const DiseaseHeatmapScreen(),
        '/market': (context) => const MarketPricesScreen(),
        '/schemes': (context) => const GovSchemesScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/finance': (context) => const FinanceScreen(),
      },
    );
  }
}
