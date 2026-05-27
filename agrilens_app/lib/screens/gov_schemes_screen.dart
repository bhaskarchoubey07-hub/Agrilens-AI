import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';

class GovSchemesScreen extends StatefulWidget {
  const GovSchemesScreen({super.key});

  @override
  State<GovSchemesScreen> createState() => _GovSchemesScreenState();
}

class _GovSchemesScreenState extends State<GovSchemesScreen> {
  bool _isLoading = true;
  List<dynamic> _schemes = [];

  @override
  void initState() {
    super.initState();
    _loadSchemes();
  }

  Future<void> _loadSchemes() async {
    final localizations = Provider.of<AppLocalizations>(context, listen: false);
    // Fetch schemes based on default profile values
    final data = await ApiService.getGovernmentSchemes(2.0, "wheat", localizations.locale);
    if (mounted) {
      setState(() {
        _schemes = data;
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
        title: Text(localizations.translate('schemes')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSchemes,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      localizations.translate('scheme_eligible'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _schemes.length,
                        itemBuilder: (context, index) {
                          final scheme = _schemes[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Scheme Title
                                  Text(
                                    scheme['title'] ?? '',
                                    style: TextStyle(
                                      fontSize: 20, 
                                      fontWeight: FontWeight.bold, 
                                      color: isDark ? Colors.green[300] : Colors.green[900]
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Eligibility info
                                  _buildSchemeDetailRow(
                                    context,
                                    localizations.locale == 'hi' ? "योग्यता" : "Eligibility",
                                    scheme['eligibility'] ?? '',
                                    Icons.person_pin
                                  ),
                                  const SizedBox(height: 8),

                                  // Subsidy benefit info
                                  _buildSchemeDetailRow(
                                    context,
                                    localizations.locale == 'hi' ? "लाभ/सब्सिडी" : "Benefit/Subsidy",
                                    scheme['subsidy'] ?? '',
                                    Icons.monetization_on
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Description
                                  Text(
                                    scheme['description'] ?? '',
                                    style: const TextStyle(fontSize: 16, height: 1.4),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Apply Button
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 50.0),
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                    ),
                                    onPressed: () {
                                      // Launch Government Portal link in production browser
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            localizations.locale == 'hi' 
                                                ? "सरकारी पोर्टल लिंक खोला जा रहा है..." 
                                                : "Opening official government portal..."
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.open_in_new, color: Colors.white),
                                    label: Text(
                                      localizations.locale == 'hi' ? "आवेदन करें / विवरण" : "Apply / Details",
                                      style: const TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSchemeDetailRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: Theme.of(context).colorScheme.secondary
            ),
          ),
        ),
      ],
    );
  }
}
