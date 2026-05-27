import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../services/tflite_service.dart';

class CropScannerScreen extends StatefulWidget {
  const CropScannerScreen({super.key});

  @override
  State<CropScannerScreen> createState() => _CropScannerScreenState();
}

class _CropScannerScreenState extends State<CropScannerScreen> {
  File? _imageFile;
  bool _isProcessing = false;
  Map<String, dynamic>? _scanResult;
  final TfliteService _tfliteService = TfliteService();

  @override
  void initState() {
    super.initState();
    _tfliteService.loadModel();
  }

  @override
  void dispose() {
    _tfliteService.dispose();
    super.dispose();
  }

  // Choose image source: Camera or Gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _scanResult = null;
          _isProcessing = true;
        });

        // Run scan via API or fallback local TFLite model
        _runInference();
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _runInference() async {
    if (_imageFile == null) return;
    
    final localizations = Provider.of<AppLocalizations>(context, listen: false);
    Map<String, dynamic> result;
    
    // First attempt local on-device TFLite inference for low memory/offline speed
    try {
      result = await _tfliteService.classifyImage(_imageFile!, localizations.locale);
    } catch (e) {
      // If TFLite fails, call API Service which includes online/offline smart fallbacks
      result = await ApiService.scanCrop(_imageFile!, localizations.locale);
    }

    setState(() {
      _scanResult = result;
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = Provider.of<AppLocalizations>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('scan_crop')),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display Chosen Image or Placeholder
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_search, size: 64, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 12),
                          Text(
                            localizations.translate('scan_crop'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 20),

              // Control Buttons - Large Touch Targets
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
                      label: Text(localizations.translate('open_camera')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: Icon(Icons.photo_library, color: Theme.of(context).colorScheme.primary, size: 28),
                      label: Text(
                        localizations.translate('upload_gallery'),
                        style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Scanning Status Indicator
              if (_isProcessing)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text("AI विश्लेषण किया जा रहा है... (AI Analyzing Leaf...)", style: TextStyle(fontSize: 18)),
                  ],
                ),

              // AI Output Results Report
              if (_scanResult != null && !_isProcessing) ...[
                Card(
                  color: isDark ? const Color(0xFF2E7D32).withOpacity(0.2) : Colors.green[50],
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.green[700]!, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _scanResult!['disease_name'] ?? 'Unknown Disease',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[900]),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getSeverityColor(_scanResult!['severity']),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${localizations.translate('severity')}: ${_scanResult!['severity']}",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${localizations.translate('confidence')}: ${(_scanResult!['confidence'] as num).toStringAsFixed(1)}%",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        const Divider(height: 24),
                        
                        // Treatment Indicators
                        _buildTreatmentStat(
                          Icons.currency_rupee, 
                          localizations.translate('est_cost'), 
                          "₹${_scanResult!['estimated_cost_inr']}",
                          Colors.blue[900]!
                        ),
                        const SizedBox(height: 8),
                        _buildTreatmentStat(
                          Icons.health_and_safety, 
                          localizations.translate('crop_saved'), 
                          "${_scanResult!['crop_saved_percentage']}%",
                          Colors.green[900]!
                        ),
                        const SizedBox(height: 8),
                        _buildTreatmentStat(
                          Icons.hourglass_empty, 
                          localizations.translate('time_to_act'), 
                          "${_scanResult!['time_to_act']}",
                          Colors.red[900]!
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Recommended Actions list
                Text(
                  localizations.translate('recommended_actions'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ...?(_scanResult!['recommended_actions'] as List<dynamic>?)?.map((action) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              action.toString(),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTreatmentStat(IconData icon, String title, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 28, color: color),
        const SizedBox(width: 8),
        Text("$title: ", style: const TextStyle(fontSize: 16)),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
