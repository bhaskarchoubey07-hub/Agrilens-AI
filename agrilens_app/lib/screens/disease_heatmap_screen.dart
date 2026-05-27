import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';

class DiseaseHeatmapScreen extends StatefulWidget {
  const DiseaseHeatmapScreen({super.key});

  @override
  State<DiseaseHeatmapScreen> createState() => _DiseaseHeatmapScreenState();
}

class _DiseaseHeatmapScreenState extends State<DiseaseHeatmapScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _alertsData = {};

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    final localizations = Provider.of<AppLocalizations>(context, listen: false);
    final data = await ApiService.getDiseaseAlerts(26.9124, 75.7873, localizations.locale);
    if (mounted) {
      setState(() {
        _alertsData = data;
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
        title: Text(localizations.translate('heatmap')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAlerts,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // High-priority status warning card
                      Card(
                        color: Colors.red[900],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber, color: Colors.white, size: 40),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      localizations.translate('pest_risk_alert'),
                                      style: const TextStyle(
                                        color: Colors.white, 
                                        fontSize: 18, 
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      localizations.locale == 'hi' 
                                          ? "सावधानी रखें! 2 बीमारियां रिपोर्ट की गई हैं।" 
                                          : "Take precautions! 2 outbreak vectors reported.",
                                      style: const TextStyle(color: Colors.white70, fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Interactive Neighborhood Sector Outbreak Diagram (Simulated Map)
                      Text(
                        localizations.locale == 'hi' ? "आपके नजदीकी क्षेत्रों की स्थिति" : "Status of Surrounding Areas",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.green[50],
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey[400]!, width: 2),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Grid grid lines
                            CustomPaint(
                              painter: MapGridPainter(isDark: isDark),
                              size: Size.infinite,
                            ),
                            // Center farmer icon
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.green[800],
                              child: const Icon(Icons.home, color: Colors.white, size: 20),
                            ),
                            // Disease dot 1 (Within 1.2km)
                            Positioned(
                              top: 50,
                              left: 80,
                              child: _buildMapPin(context, "Wheat Rust", Colors.red),
                            ),
                            // Disease dot 2 (Within 4.8km)
                            Positioned(
                              bottom: 60,
                              right: 70,
                              child: _buildMapPin(context, "Tomato Blight", Colors.orange),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // List details of active vectors
                      Text(
                        localizations.locale == 'hi' ? "सक्रिय बीमारियां" : "Active Diseases",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      ...?(_alertsData['alerts'] as List<dynamic>?)?.map((alert) {
                        final isHigh = alert['severity'] == 'High';
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: (isHigh ? Colors.red : Colors.orange).withOpacity(0.12),
                              child: Icon(
                                Icons.bug_report, 
                                color: isHigh ? Colors.red : Colors.orange, 
                                size: 28
                              ),
                            ),
                            title: Text(
                              alert['disease'] ?? '',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  "${alert['distance']} • ${alert['reported_count']} ${localizations.locale == 'hi' ? 'रिपोर्ट' : 'reports'}",
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  alert['message'] ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildMapPin(BuildContext context, String label, Color color) {
    return Column(
      children: [
        Icon(Icons.location_on, color: color, size: 36),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
      ],
    );
  }
}

// Custom Painter to draw a clean coordinate lattice grid representing farmland boundaries
class MapGridPainter extends CustomPainter {
  final bool isDark;
  MapGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white12 : Colors.black12
      ..strokeWidth = 1.0;

    // Draw horizontal lines
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    // Draw vertical lines
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Draw circular search boundary
    final circlePaint = Paint()
      ..color = Colors.green.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 70, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
