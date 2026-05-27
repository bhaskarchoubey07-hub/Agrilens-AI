import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _weatherData = {};

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final localizations = Provider.of<AppLocalizations>(context, listen: false);
    // Lat/Lng for Jaipur Central Mandi / farming area
    final data = await ApiService.getWeather(26.9124, 75.7873, localizations.locale);
    if (mounted) {
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = Provider.of<AppLocalizations>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('weather')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWeather,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Current Temp & Overview Card
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        color: isDark ? const Color(0xFF1A237E).withOpacity(0.3) : const Color(0xFFE8EAF6),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Icon(Icons.wb_cloudy, size: 72, color: Colors.blue[800]),
                              const SizedBox(height: 12),
                              Text(
                                _weatherData['temperature'] ?? '32°C',
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${localizations.translate('weather')}: ${_weatherData['rain_forecast']}",
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Irrigation recommendation ALERT BOX
                      Card(
                        elevation: 4.0,
                        color: Colors.green[800],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info, color: Colors.white, size: 28),
                                  const SizedBox(width: 8),
                                  Text(
                                    localizations.translate('irrigation_rec'),
                                    style: const TextStyle(
                                      color: Colors.white, 
                                      fontSize: 20, 
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _weatherData['irrigation_recommendation'] ?? '',
                                style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Weather Details Grid List
                      _buildWeatherDetailTile(
                        context,
                        localizations.locale == 'hi' ? "वर्षा की संभावना" : "Rain Probability",
                        _weatherData['rain_probability'] ?? '20%',
                        Icons.umbrella,
                        Colors.blue,
                      ),
                      _buildWeatherDetailTile(
                        context,
                        localizations.locale == 'hi' ? "नमी (Humidity)" : "Humidity",
                        _weatherData['humidity'] ?? '65%',
                        Icons.water_drop,
                        Colors.teal,
                      ),
                      _buildWeatherDetailTile(
                        context,
                        localizations.locale == 'hi' ? "हवा की गति (Wind)" : "Wind Speed",
                        _weatherData['wind_speed'] ?? '10 km/h',
                        Icons.air,
                        Colors.blueGrey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildWeatherDetailTile(BuildContext context, String label, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
