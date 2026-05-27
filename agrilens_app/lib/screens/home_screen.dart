import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

class HomeDashboard extends StatefulWidget {
  final VoidCallback toggleTheme;
  final ThemeMode currentThemeMode;

  const HomeDashboard({
    super.key,
    required this.toggleTheme,
    required this.currentThemeMode,
  });

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final localizations = Provider.of<AppLocalizations>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.grass, color: Colors.white, size: 28.0),
            const SizedBox(width: 8.0),
            Text(localizations.translate('app_name')),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(widget.currentThemeMode == ThemeMode.light 
              ? Icons.dark_mode 
              : Icons.light_mode
            ),
            onPressed: widget.toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              localizations.setLocale(localizations.locale == 'hi' ? 'en' : 'hi');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Farm Health Score Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        localizations.translate('farm_score'),
                        style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Radial Progress Ring
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: CircularProgressIndicator(
                                  value: 0.85, // 85% Health Score
                                  strokeWidth: 12.0,
                                  color: Colors.green[700],
                                  backgroundColor: Colors.grey[300],
                                ),
                              ),
                              const Text(
                                "85",
                                style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          // Summary Stats
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSummaryRow(
                                context,
                                localizations.translate('disease_risk'),
                                localizations.translate('low'),
                                Colors.green,
                                Icons.bug_report,
                              ),
                              const SizedBox(height: 8.0),
                              _buildSummaryRow(
                                context,
                                localizations.translate('water_risk'),
                                localizations.translate('medium'),
                                Colors.orange,
                                Icons.water_drop,
                              ),
                              const SizedBox(height: 8.0),
                              _buildSummaryRow(
                                context,
                                localizations.translate('profit_outlook'),
                                localizations.translate('good'),
                                Colors.green,
                                Icons.trending_up,
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              
              // Grid Dashboard Menu (Expanded to 8 items to include Finance Hub & Profit Analytics)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.15,
                children: [
                  _buildMenuCard(
                    context,
                    localizations.translate('scan'),
                    Icons.camera_alt,
                    Colors.green[800]!,
                    () => Navigator.pushNamed(context, '/scan'),
                  ),
                  _buildMenuCard(
                    context,
                    localizations.translate('weather'),
                    Icons.wb_sunny,
                    Colors.orange[800]!,
                    () => Navigator.pushNamed(context, '/weather'),
                  ),
                  _buildMenuCard(
                    context,
                    localizations.translate('soil'),
                    Icons.opacity,
                    Colors.brown[700]!,
                    () => Navigator.pushNamed(context, '/soil'),
                  ),
                  _buildMenuCard(
                    context,
                    localizations.translate('market'),
                    Icons.store,
                    Colors.blue[800]!,
                    () => Navigator.pushNamed(context, '/market'),
                  ),
                  _buildMenuCard(
                    context,
                    localizations.translate('schemes'),
                    Icons.account_balance,
                    Colors.teal[800]!,
                    () => Navigator.pushNamed(context, '/schemes'),
                  ),
                  _buildMenuCard(
                    context,
                    localizations.translate('heatmap'),
                    Icons.map,
                    Colors.red[800]!,
                    () => Navigator.pushNamed(context, '/heatmap'),
                  ),
                  _buildMenuCard(
                    context,
                    localizations.translate('finance_hub'),
                    Icons.monetization_on,
                    Colors.amber[800]!,
                    () => Navigator.pushNamed(context, '/finance'),
                  ),
                  _buildMenuCard(
                    context,
                    localizations.translate('profit_analytics'),
                    Icons.bar_chart,
                    Colors.purple[700]!,
                    () => Navigator.pushNamed(context, '/finance'),
                  ),
                ],
              ),
              const SizedBox(height: 80.0), // Padding to prevent FAB overlapping content
            ],
          ),
        ),
      ),
      
      // Floating Voice Assistant Button
      floatingActionButton: FloatingActionButton.large(
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.pushNamed(context, '/voice');
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mic, size: 40.0),
            Text(
              localizations.translate('voice_assistant'),
              style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      
      // Bottom Navigation Bar with 4 items: Home, Scan, Finance, Profile
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 14.0,
        unselectedFontSize: 12.0,
        iconSize: 30.0,
        type: BottomNavigationBarType.fixed, // Prevent scaling items shifting layout
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: localizations.translate('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.camera_alt),
            label: localizations.translate('scan'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.monetization_on),
            label: localizations.translate('finance_hub'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: localizations.translate('profile'),
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            Navigator.pushNamed(context, '/scan');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/finance');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String title, String value, Color valColor, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24.0, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8.0),
        Text("$title: ", style: const TextStyle(fontSize: 16.0)),
        Text(
          value,
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: valColor),
        ),
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28.0,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, size: 36.0, color: color),
              ),
              const SizedBox(height: 12.0),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
