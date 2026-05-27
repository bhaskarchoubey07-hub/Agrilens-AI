import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen> {
  bool _isLoading = true;
  String _marketName = "";
  String _lastUpdated = "";
  List<dynamic> _cropsList = [];

  // Calculator inputs
  final _farmSizeController = TextEditingController(text: "2");
  final _yieldController = TextEditingController(text: "15");
  String _selectedCropId = "wheat";
  Map<String, dynamic>? _profitCalculation;

  @override
  void initState() {
    super.initState();
    _loadPrices();
    _calculateProfit();
  }

  @override
  void dispose() {
    _farmSizeController.dispose();
    _yieldController.dispose();
    super.dispose();
  }

  Future<void> _loadPrices() async {
    final localizations = Provider.of<AppLocalizations>(context, listen: false);
    final data = await ApiService.getMarketPrices(localizations.locale);
    if (mounted) {
      setState(() {
        _marketName = data['market_name'] ?? '';
        _lastUpdated = data['last_updated'] ?? '';
        _cropsList = data['prices'] ?? [];
        _isLoading = false;
      });
    }
  }

  void _calculateProfit() {
    final farmSize = double.tryParse(_farmSizeController.text) ?? 0.0;
    final expectedYield = double.tryParse(_yieldController.text) ?? 0.0;
    
    // average costs & profit calculations locally using core business logic
    final calculation = ApiService.calculateProfitLocal(farmSize, _selectedCropId, expectedYield);
    setState(() {
      _profitCalculation = calculation;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = Provider.of<AppLocalizations>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('market')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mandi location banner
                    Text(
                      _marketName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      "${localizations.locale == 'hi' ? 'अंतिम अपडेट' : 'Last Updated'}: $_lastUpdated",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 16),

                    // Prices List Cards
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _cropsList.length,
                      itemBuilder: (context, index) {
                        final crop = _cropsList[index];
                        final trend = crop['trend'] as String;
                        final priceColor = trend == 'up' 
                            ? Colors.green[800] 
                            : (trend == 'down' ? Colors.red[800] : Colors.grey[800]);

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        crop['name'] ?? '',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${localizations.locale == 'hi' ? 'अगला अनुमान' : 'Next Predict'}: ₹${crop['predicted_price']}/${crop['unit']}",
                                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          trend == 'up' 
                                              ? Icons.arrow_upward 
                                              : (trend == 'down' ? Icons.arrow_downward : Icons.trending_flat),
                                          color: priceColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "₹${crop['price']}",
                                          style: TextStyle(
                                            fontSize: 22, 
                                            fontWeight: FontWeight.bold, 
                                            color: priceColor
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      crop['profit_outlook'] ?? '',
                                      style: TextStyle(
                                        fontSize: 14, 
                                        fontWeight: FontWeight.w500,
                                        color: priceColor
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Profit Forecasting Calculator Card
                    Card(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.blue[50],
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.blue[400]!, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.locale == 'hi' ? "फसल मुनाफा कैलकुलेटर" : "Crop Profit Calculator",
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            
                            // Select Crop
                            DropdownButtonFormField<String>(
                              value: _selectedCropId,
                              decoration: InputDecoration(
                                labelText: localizations.translate('crop_type'),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                fillColor: isDark ? Colors.black : Colors.white,
                                filled: true,
                              ),
                              items: const [
                                DropdownMenuItem(value: "wheat", child: Text("गेहूं (Wheat)")),
                                DropdownMenuItem(value: "paddy", child: Text("धान (Paddy)")),
                                DropdownMenuItem(value: "potato", child: Text("आलू (Potato)")),
                                DropdownMenuItem(value: "tomato", child: Text("टमाटर (Tomato)")),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedCropId = val;
                                  });
                                  _calculateProfit();
                                }
                              },
                            ),
                            const SizedBox(height: 12),

                            // Farm Size Input
                            TextField(
                              controller: _farmSizeController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 18),
                              decoration: InputDecoration(
                                labelText: "${localizations.translate('farm_size')} (${localizations.locale == 'hi' ? 'एकड़' : 'Acres'})",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                fillColor: isDark ? Colors.black : Colors.white,
                                filled: true,
                              ),
                              onChanged: (_) => _calculateProfit(),
                            ),
                            const SizedBox(height: 12),

                            // Expected Yield Input
                            TextField(
                              controller: _yieldController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 18),
                              decoration: InputDecoration(
                                labelText: localizations.locale == 'hi' 
                                    ? "अनुमानित उपज (क्विंटल/एकड़)" 
                                    : "Expected Yield (Quintal/Acre)",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                fillColor: isDark ? Colors.black : Colors.white,
                                filled: true,
                              ),
                              onChanged: (_) => _calculateProfit(),
                            ),
                            const SizedBox(height: 20),

                            // Display Profit Output Metrics
                            if (_profitCalculation != null) ...[
                              const Divider(),
                              _buildCalcResultRow(
                                localizations.locale == 'hi' ? "कुल लागत लागत" : "Total Input Cost",
                                "₹${_profitCalculation!['total_cost_inr']}",
                                Colors.red[900]!
                              ),
                              const SizedBox(height: 8),
                              _buildCalcResultRow(
                                localizations.locale == 'hi' ? "अनुमानित राजस्व" : "Gross Revenue",
                                "₹${_profitCalculation!['gross_revenue_inr']}",
                                Colors.green[900]!
                              ),
                              const SizedBox(height: 8),
                              _buildCalcResultRow(
                                localizations.locale == 'hi' ? "शुद्ध लाभ मुनाफा" : "Estimated Net Profit",
                                "₹${_profitCalculation!['net_profit_inr']}",
                                Colors.green[800]!,
                                isHeader: true
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${localizations.locale == 'hi' ? 'रिटर्न (ROI)' : 'Return of Investment'}: ${_profitCalculation!['roi_percentage']}%",
                                style: TextStyle(
                                  fontSize: 16, 
                                  fontWeight: FontWeight.bold, 
                                  color: Colors.blue[900]
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCalcResultRow(String label, String value, Color color, {bool isHeader = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isHeader ? 18 : 16, 
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHeader ? 22 : 18, 
            fontWeight: FontWeight.bold, 
            color: color
          ),
        ),
      ],
    );
  }
}

