import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final ThemeMode currentThemeMode;

  const LoginScreen({
    super.key,
    required this.toggleTheme,
    required this.currentThemeMode,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendOtp(String label) {
    if (_phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(label)),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    // Simulate API Network call
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
        _otpSent = true;
      });
    });
  }

  void _verifyOtp() {
    if (_otpController.text.length < 4) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
      // Navigate to Home Dashboard
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  void _googleSignIn() {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = Provider.of<AppLocalizations>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('login')),
        actions: [
          IconButton(
            icon: Icon(widget.currentThemeMode == ThemeMode.light 
              ? Icons.dark_mode 
              : Icons.light_mode
            ),
            onPressed: widget.toggleTheme,
          ),
          // Language Quick Toggle
          TextButton(
            onPressed: () {
              localizations.setLocale(localizations.locale == 'hi' ? 'en' : 'hi');
            },
            child: Text(
              localizations.locale == 'hi' ? 'EN' : 'हिं',
              style: const TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16.0),
              // Help illustration
              Icon(
                Icons.account_circle,
                size: 100.0,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24.0),
              
              if (!_otpSent) ...[
                // Phone input field
                Text(
                  localizations.translate('phone_hint'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 22.0),
                  maxLength: 10,
                  decoration: InputDecoration(
                    prefixText: '+91 ',
                    prefixStyle: const TextStyle(fontSize: 22.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    contentPadding: const EdgeInsets.all(20.0),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _sendOtp(
                    localizations.locale == 'hi' ? 'कृपया सही मोबाइल नंबर दर्ज करें' : 'Please enter a valid phone number'
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(localizations.translate('get_otp')),
                ),
              ] else ...[
                // OTP code field
                Text(
                  localizations.translate('otp_hint'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 24.0, letterSpacing: 10.0),
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    contentPadding: const EdgeInsets.all(20.0),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(localizations.translate('verify_otp')),
                ),
                const SizedBox(height: 12.0),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _otpSent = false;
                      _otpController.clear();
                    });
                  },
                  child: Text(
                    localizations.locale == 'hi' ? 'नंबर बदलें' : 'Change Number',
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
              ],
              
              const SizedBox(height: 32.0),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      localizations.locale == 'hi' ? 'अथवा' : 'OR',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 32.0),
              
              // Google Login Button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60.0),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                onPressed: _isLoading ? null : _googleSignIn,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.g_mobiledata, size: 40.0),
                    const SizedBox(width: 8.0),
                    Text(
                      localizations.translate('google_login'),
                      style: TextStyle(
                        fontSize: 20.0, 
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
              
              // Demo bypass button (for direct testing)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/home');
                },
                child: Text(
                  localizations.locale == 'hi' ? 'बिना लॉगिन सीधे चलाएं (डेमो)' : 'Direct Bypass / Demo Mode',
                  style: const TextStyle(color: Colors.grey, fontSize: 16.0, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
