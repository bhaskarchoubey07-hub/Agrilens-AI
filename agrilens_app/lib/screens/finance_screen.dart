import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _ProfileConfig {
  double farmSize = 2.0;
  String cropType = "wheat";
  double prevHarvest = 15.0;
  double inputExpenses = 18000.0;
  double weatherRisk = 0.3; // 30% risk
}

class _FinanceScreenState extends State<FinanceScreen> {
  // Subscription Plan (false = Free, true = Premium)
  bool _isPremium = true; 
  
  final _profile = _ProfileConfig();
  bool _isLoading = false;
  
  // Dashboard & Loans States
  Map<String, dynamic> _scoreData = {};
  Map<String, dynamic> _loanData = {};
  List<dynamic> _marketplaceProducts = [];
  List<dynamic> _insurancePolicies = [];
  Map<String, dynamic> _sellingAdvice = {};

  // Expense Tracker list
  final List<Map<String, dynamic>> _userExpenses = [
    {"category": "Seeds", "cost": 3500.0, "icon": Icons.grain},
    {"category": "Fertilizers", "cost": 5000.0, "icon": Icons.eco},
    {"category": "Labor", "cost": 4000.0, "icon": Icons.people},
    {"category": "Water cost", "cost": 1500.0, "icon": Icons.water_drop},
    {"category": "Machinery", "cost": 3000.0, "icon": Icons.minor_crash},
    {"category": "Other expenses", "cost": 1500.0, "icon": Icons.more_horiz},
  ];

  // Temp expense input controllers
  final _expenseNameController = TextEditingController();
  final _expenseCostController = TextEditingController();
  String _expenseCategoryKey = "Seeds";

  @override
  void initState() {
    super.initState();
    _loadFinanceData();
  }

  @override
  void dispose() {
    _expenseNameController.dispose();
    _expenseCostController.dispose();
    super.dispose();
  }

  Future<void> _loadFinanceData() async {
    setState(() {
      _isLoading = true;
    });

    final localizations = Provider.of<AppLocalizations>(context, listen: false);

    // Call endpoints (which fallback to local calculations offline)
    final score = await ApiService.getFinanceDashboard(_profile.farmSize, _profile.cropType, localizations.locale);
    final loan = await ApiService.checkLoanEligibility(
      farmSize: _profile.farmSize,
      cropType: _profile.cropType,
      prevHarvest: _profile.prevHarvest,
      inputExpenses: _profile.inputExpenses,
      weatherRisk: _profile.weatherRisk,
    );
    final products = await ApiService.getMarketplaceProducts("wheat_rust", _profile.farmSize, localizations.locale);
    final insurance = await ApiService.getInsurancePolicies(_profile.weatherRisk, localizations.locale);
    final selling = await ApiService.getSellingAdvice(_profile.cropType, 2100.0, localizations.locale);

    if (mounted) {
      setState(() {
        _scoreData = score;
        _loanData = loan;
        _marketplaceProducts = products;
        _insurancePolicies = insurance;
        _sellingAdvice = selling;
        _isLoading = false;
      });
    }
  }

  // Calculate totals for expense tracker monthly spending reports
  double get _totalExpensesSum {
    return _userExpenses.fold(0.0, (sum, item) => sum + (item['cost'] as double));
  }

  double get _expectedRevenue {
    // Wheat: 15 quintals per acre * 2 acres * 2100 currentMandiprice
    return _profile.prevHarvest * 2100.0;
  }

  double get _expectedProfit {
    return _expectedRevenue - _totalExpensesSum;
  }

  // Dialogue box to add a custom expense item
  void _showAddExpenseDialog(AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(localizations.translate('add_expense_btn')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _expenseCategoryKey,
                    items: const [
                      DropdownMenuItem(value: "Seeds", child: Text("बीज (Seeds)")),
                      DropdownMenuItem(value: "Fertilizers", child: Text("खाद (Fertilizers)")),
                      DropdownMenuItem(value: "Labor", child: Text("मजदूरी (Labor)")),
                      DropdownMenuItem(value: "Water cost", child: Text("पानी/सिंचाई (Water)")),
                      DropdownMenuItem(value: "Machinery", child: Text("मशीनरी (Machinery)")),
                      DropdownMenuItem(value: "Other expenses", child: Text("अन्य खर्च (Other)")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          _expenseCategoryKey = val;
                        });
                      }
                    },
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _expenseCostController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: localizations.locale == 'hi' ? "खर्च राशि (रु)" : "Expense Cost (Rs)",
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(localizations.locale == 'hi' ? "रद्द करें" : "Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final cost = double.tryParse(_expenseCostController.text) ?? 0.0;
                    if (cost > 0) {
                      setState(() {
                        _userExpenses.add({
                          "category": _expenseCategoryKey,
                          "cost": cost,
                          "icon": _getCategoryIcon(_expenseCategoryKey)
                        });
                      });
                      _expenseCostController.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(localizations.locale == 'hi' ? "जोड़ें" : "Add"),
                )
              ],
            );
          },
        );
      },
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'Seeds': return Icons.grain;
      case 'Fertilizers': return Icons.eco;
      case 'Labor': return Icons.people;
      case 'Water cost': return Icons.water_drop;
      case 'Machinery': return Icons.minor_crash;
      default: return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = Provider.of<AppLocalizations>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('finance_hub')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SUBSCRIPTION TIER CONTROL BAR
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: isDark ? const Color(0xFF1B5E20).withOpacity(0.2) : Colors.green[50],
                    child: Row(
                      children: [
                        Icon(Icons.stars, color: Colors.amber[800], size: 28),
                        const SizedBox(width: 8),
                        Text(
                          localizations.translate('sub_model'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            ChoiceChip(
                              label: Text(localizations.translate('free_plan')),
                              selected: !_isPremium,
                              onSelected: (val) {
                                if (val) setState(() => _isPremium = false);
                              },
                            ),
                            const SizedBox(width: 6),
                            ChoiceChip(
                              label: Text(localizations.translate('premium_plan')),
                              selected: _isPremium,
                              selectedColor: Colors.amber[700],
                              labelStyle: TextStyle(
                                color: _isPremium ? Colors.black : (isDark ? Colors.white : Colors.black87),
                                fontWeight: FontWeight.bold
                              ),
                              onSelected: (val) {
                                if (val) setState(() => _isPremium = true);
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        
                        // 1. FINANCIAL HEALTH SCORE CARD (Visible to all)
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      localizations.translate('finance_health_score'),
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "${_scoreData['financial_score'] ?? '84'}/100",
                                      style: const TextStyle(
                                        fontSize: 26, 
                                        fontWeight: FontWeight.bold, 
                                        color: Colors.green
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const LinearProgressIndicator(
                                  value: 0.84,
                                  minHeight: 8,
                                  color: Colors.green,
                                ),
                                const SizedBox(height: 16),
                                
                                // Score breakdown
                                if (_scoreData['breakdown'] != null) ...[
                                  _buildHealthBreakdownRow(
                                    localizations.translate('profit_potential'), 
                                    _scoreData['breakdown']['profit_potential'], 
                                    Colors.green
                                  ),
                                  _buildHealthBreakdownRow(
                                    localizations.translate('expense_control'), 
                                    _scoreData['breakdown']['expense_control'], 
                                    Colors.orange
                                  ),
                                  _buildHealthBreakdownRow(
                                    localizations.translate('loan_risk'), 
                                    _scoreData['breakdown']['loan_risk'], 
                                    Colors.green
                                  ),
                                  _buildHealthBreakdownRow(
                                    localizations.translate('water_risk'), 
                                    _scoreData['breakdown']['weather_risk'], 
                                    Colors.orange
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 2. EXPENSE TRACKER LEDGER (Visible to all)
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      localizations.translate('expense_tracker'),
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        minimumSize: const Size(60, 40),
                                      ),
                                      onPressed: () => _showAddExpenseDialog(localizations),
                                      icon: const Icon(Icons.add, size: 18),
                                      label: Text(
                                        localizations.locale == 'hi' ? "जोड़ें" : "Add", 
                                        style: const TextStyle(fontSize: 14)
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // List of added expenses
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _userExpenses.length,
                                  itemBuilder: (context, index) {
                                    final exp = _userExpenses[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                                      child: Row(
                                        children: [
                                          Icon(exp['icon'] as IconData, size: 24, color: Colors.brown[700]),
                                          const SizedBox(width: 8),
                                          Text(
                                            localizations.translate('item_${exp['category'].toLowerCase().replaceAll(" ", "_")}'),
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                          const Spacer(),
                                          Text(
                                            "₹${(exp['cost'] as double).round()}",
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const Divider(height: 24),
                                
                                // Monthly Spending Report Summary
                                Text(
                                  localizations.translate('spending_report'),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                _buildSpendingReportRow(localizations.translate('total_expenses'), "₹${_totalExpensesSum.round()}", Colors.red[800]!),
                                _buildSpendingReportRow(localizations.translate('expected_rev'), "₹${_expectedRevenue.round()}", Colors.blue[800]!),
                                _buildSpendingReportRow(
                                  localizations.translate('expected_profit'), 
                                  "₹${_expectedProfit.round()}", 
                                  Colors.green[800]!, 
                                  isHeader: true
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 3. AI MICRO-LOAN ELIGIBILITY ENGINE (Premium locked)
                        _buildLocker(
                          localizations,
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizations.translate('loan_eligibility'),
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${localizations.translate('loan_eligibility')}: ${_loanData['loan_eligibility']}",
                                        style: TextStyle(
                                          fontSize: 18, 
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber[900]
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green[100],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          "Risk: ${_loanData['risk_level']}",
                                          style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "${localizations.translate('suggested_amt')}: ₹${_loanData['suggested_amount_min']} – ₹${_loanData['suggested_amount_max']}",
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${localizations.translate('emi_payment')}: ₹${(_loanData['estimated_monthly_payment'] as num?)?.round()}/Month",
                                    style: TextStyle(fontSize: 16, color: Colors.blue[900], fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Finance options
                                  const Text("उपलब्ध ऋण श्रेणियां (Available Loans):", style: TextStyle(fontWeight: FontWeight.bold)),
                                  _buildFinanceOptionRow("बीज ऋण (Seed Loan)", "9.5% per annum"),
                                  _buildFinanceOptionRow("खाद ऋण (Fertilizer Loan)", "10.0% per annum"),
                                  _buildFinanceOptionRow("उपकरण ऋण (Equipment Loan)", "11.5% per annum"),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 4. SMART CROP MEDICINE MARKETPLACE (Premium locked)
                        _buildLocker(
                          localizations,
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizations.locale == 'hi' ? "स्मार्ट कवकनाशी स्टोर (Marketplace)" : "Crop Medicine Marketplace",
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Recommendations based on Leaf Scan Rust key
                                  const Text(
                                    "फसल रोग 'गेहूं रस्ट' के आधार पर सुझाई गई दवाएं:",
                                    style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _marketplaceProducts.length,
                                    itemBuilder: (context, index) {
                                      final prod = _marketplaceProducts[index];
                                      return Card(
                                        color: isDark ? Colors.black54 : Colors.grey[100],
                                        margin: const EdgeInsets.only(bottom: 12),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    prod['name'] ?? '',
                                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                  ),
                                                  Text(
                                                    "₹${prod['price']}",
                                                    style: TextStyle(
                                                      fontSize: 18, 
                                                      fontWeight: FontWeight.bold,
                                                      color: Theme.of(context).colorScheme.primary
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "मात्रा सलाह: ${prod['quantity_recommended']} ${prod['unit']}",
                                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                              ),
                                              Text("कुल उपचार लागत: ₹${prod['estimated_cost']}"),
                                              Text(
                                                "नजदीकी उपलब्धता: ${prod['store_availability']}",
                                                style: const TextStyle(fontSize: 12, color: Colors.blue),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        minimumSize: const Size(50, 40),
                                                        padding: EdgeInsets.zero,
                                                      ),
                                                      onPressed: () {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text("Ordering Product...")),
                                                        );
                                                      },
                                                      child: Text(localizations.translate('buy_now'), style: const TextStyle(fontSize: 14)),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: OutlinedButton(
                                                      style: OutlinedButton.styleFrom(
                                                        minimumSize: const Size(50, 40),
                                                        padding: EdgeInsets.zero,
                                                        side: BorderSide(color: Theme.of(context).colorScheme.primary)
                                                      ),
                                                      onPressed: () {},
                                                      child: Text(localizations.translate('save_cart'), style: const TextStyle(fontSize: 14)),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 5. SMART INSURANCE ASSISTANT (Visible to all)
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizations.translate('insurance'),
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.red[200]!),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.info, color: Colors.red),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _insurancePolicies.isNotEmpty 
                                              ? _insurancePolicies[0]['explanation'] 
                                              : '',
                                          style: TextStyle(color: Colors.red[900], fontSize: 15, fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ..._insurancePolicies.map((pol) {
                                  return ListTile(
                                    leading: const Icon(Icons.security, color: Colors.green),
                                    title: Text(pol['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text("प्रीमियम: ${pol['premium_rate']} • ${pol['coverage']}"),
                                    trailing: Text("₹${pol['cost_per_acre']}/Ac"),
                                  );
                                }).toList()
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 6. HARVEST SELLING ASSISTANT (Premium locked)
                        _buildLocker(
                          localizations,
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizations.translate('selling_assistant'),
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Mandi predictions
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildPricePredictCol(
                                        localizations.translate('current_mandi_price'), 
                                        "₹${_sellingAdvice['current_price']?.round()}/क्विंटल", 
                                        Colors.grey[700]!
                                      ),
                                      const Icon(Icons.trending_up, color: Colors.green, size: 36),
                                      _buildPricePredictCol(
                                        localizations.translate('expected_next_week'), 
                                        "₹${_sellingAdvice['predicted_price_next_week']?.round()}/क्विंटल", 
                                        Colors.green[800]!
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  
                                  // Selling advice alert box
                                  Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      border: Border.all(color: Colors.green[400]!),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.timer, color: Colors.green),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _sellingAdvice['recommendation'] ?? '',
                                            style: TextStyle(color: Colors.green[900], fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildLocker(AppLocalizations localizations, {required Widget child}) {
    if (_isPremium) return child;
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: 0.25,
          child: AbsorbPointer(child: child),
        ),
        // Premium padlock overlay
        Card(
          color: Colors.amber[700],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  localizations.translate('unlock_premium'),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildHealthBreakdownRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildSpendingReportRow(String label, String value, Color color, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isHeader ? 17 : 15, 
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHeader ? 19 : 16, 
              fontWeight: FontWeight.bold, 
              color: color
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceOptionRow(String title, String rates) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14)),
          Text(rates, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPricePredictCol(String title, String val, Color valColor) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: valColor)),
      ],
    );
  }
}
