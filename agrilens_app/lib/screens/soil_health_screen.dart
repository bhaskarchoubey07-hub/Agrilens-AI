import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

class SoilHealthScreen extends StatelessWidget {
  const SoilHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = Provider.of<AppLocalizations>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Static soil health details (could fetch from ApiService offline fallback in production)
    const double moisture = 68.0; // 68%
    const double ph = 6.8;        // Neutral / Optimal
    const double temp = 24.5;     // Celcius
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('soil')),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Overall Soil Status Overview
              Card(
                color: isDark ? const Color(0xFF3E2723).withOpacity(0.3) : const Color(0xFFEFEBE9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.brown[700],
                        child: const Icon(Icons.grass, color: Colors.white, size: 36),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.locale == 'hi' ? "मिट्टी की सेहत: बहुत बढ़िया" : "Soil Status: Excellent",
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              localizations.locale == 'hi' ? "आपकी मिट्टी बोने के लिए अनुकूल है।" : "Your soil is in optimal condition.",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 1. Soil Moisture Gauge
              _buildMetricCard(
                context,
                localizations.translate('soil_moisture'),
                "$moisture%",
                Icons.water,
                Colors.blue,
                child: LinearProgressIndicator(
                  value: moisture / 100,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue,
                  backgroundColor: Colors.blue.withOpacity(0.2),
                ),
              ),
              const SizedBox(height: 16),

              // 2. pH Scale visual indicator
              _buildMetricCard(
                context,
                localizations.translate('soil_ph'),
                "$ph (सामान्य / Neutral)",
                Icons.science,
                Colors.purple,
                child: Column(
                  children: [
                    // Visual pH scale bar
                    Container(
                      height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(
                          colors: [
                            Colors.red,     // Acidic
                            Colors.yellow,
                            Colors.green,   // Neutral (pH 7)
                            Colors.blue,
                            Colors.purple   // Alkaline
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Pointer arrow for current pH
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("0 (अम्लीय)", style: TextStyle(fontSize: 12)),
                        // Dynamic alignment approximation for pH 6.8
                        Padding(
                          padding: const EdgeInsets.only(right: 60.0),
                          child: Icon(Icons.arrow_drop_up, size: 24, color: Colors.green[900]),
                        ),
                        const Text("14 (क्षारीय)", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Soil Temperature
              _buildMetricCard(
                context,
                localizations.translate('soil_temp'),
                "$temp°C",
                Icons.thermostat,
                Colors.orange,
                child: Container(), // Empty, simple value display is sufficient
              ),
              const SizedBox(height: 16),

              // 4. Nutrient conditions (N-P-K bar graph)
              _buildMetricCard(
                context,
                localizations.translate('soil_nutrients'),
                "",
                Icons.eco,
                Colors.green,
                child: Column(
                  children: [
                    _buildNutrientBar(
                      localizations.locale == 'hi' ? "नाइट्रोजन (N) - पर्याप्त" : "Nitrogen (N) - Sufficient",
                      0.8,
                      Colors.green[700]!,
                    ),
                    const SizedBox(height: 12),
                    _buildNutrientBar(
                      localizations.locale == 'hi' ? "फास्फोरस (P) - सामान्य" : "Phosphorus (P) - Normal",
                      0.5,
                      Colors.orange[700]!,
                    ),
                    const SizedBox(height: 12),
                    _buildNutrientBar(
                      localizations.locale == 'hi' ? "पोटेशियम (K) - पर्याप्त" : "Potassium (K) - Sufficient",
                      0.85,
                      Colors.green[700]!,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, 
    String title, 
    String value, 
    IconData icon, 
    Color color, 
    {required Widget child}
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (value.isNotEmpty)
                  Text(
                    value,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientBar(String label, double value, Color barColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: value,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
          color: barColor,
          backgroundColor: barColor.withOpacity(0.15),
        ),
      ],
    );
  }
}
