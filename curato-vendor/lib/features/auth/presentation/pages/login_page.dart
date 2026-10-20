import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curato_vendor/core/services/service_locator.dart';
import 'package:curato_vendor/core/services/api_service.dart';
import 'package:curato_vendor/core/constants/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _bannerUrl;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  Future<void> _loadBanner() async {
    try {
      final dio = sl<ApiService>().dio;
      final response = await dio.get('/home/banners');
      if (response.statusCode == 200 && response.data != null) {
        final List banners = response.data['data'] ?? [];
        final vendorAuthBanner = banners.firstWhere(
          (b) => b['type'] == 'vendor_auth' && b['isActive'] == true,
          orElse: () => null,
        );
        if (vendorAuthBanner != null && vendorAuthBanner['imageUrl'] != null) {
          if (mounted) {
            setState(() {
              _bannerUrl = vendorAuthBanner['imageUrl'];
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading vendor auth banner: $e');
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      final dio = sl<ApiService>().dio;
      final response = await dio.post('/vendor/login', data: {
        'email': _emailController.text,
        'password': _passwordController.text,
      });

        if (response.statusCode == 200) {
          final token = response.data['token'];
          final userData = response.data['data'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('vendor_token', token);
          await prefs.setString('vendor_name', userData['name'] ?? 'Vendor');
          await prefs.setString('vendor_email', userData['email'] ?? '');
          
          if (mounted) {
            context.go('/');
          }
        }
    } on DioException catch (e) {
      String errorMessage = 'Login failed';
      if (e.response?.data != null && e.response?.data is Map) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else if (e.response?.data != null && e.response?.data is String) {
        if (e.response!.data.toString().contains('Cannot POST')) {
          errorMessage = 'API Route not found (404). Please check backend deployment.';
        } else {
          errorMessage = 'Server error: ${e.response?.statusCode}';
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword(String email) async {
    try {
      final dio = sl<ApiService>().dio;
      final response = await dio.post('/vendor/forgot-password', data: {'email': email});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['message'] ?? 'Reset link sent to your email')),
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to send reset link';
      if (e.response?.data != null && e.response?.data is Map) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else if (e.response?.data != null && e.response?.data is String) {
        // Handle HTML error pages or plain text errors
        if (e.response!.data.toString().contains('Cannot POST')) {
          errorMessage = 'API Route not found (404). Please check backend deployment.';
        } else {
          errorMessage = 'Server error: ${e.response?.statusCode}';
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  void _showForgotPasswordDialog() {
    final TextEditingController forgotEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Forgot Password', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your email address to receive a password reset link.', style: GoogleFonts.instrumentSans(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 20),
            TextField(
              controller: forgotEmailController,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (forgotEmailController.text.isNotEmpty) {
                _forgotPassword(forgotEmailController.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.surface),
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1100;

    final Color curatoMaroon = AppColors.primary;

    Widget formContent = Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Vendor Login',
            style: GoogleFonts.instrumentSans(fontSize: 28, fontWeight: FontWeight.w400, letterSpacing: -0.5, color: curatoMaroon),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your credentials to access your store',
            style: GoogleFonts.instrumentSans(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildField(
            'Email Address',
            'Enter email',
            _emailController,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Email is required';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildField(
            'Password',
            '••••••••',
            _passwordController,
            isPassword: true,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Password is required';
              return null;
            },
          ),
          const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _showForgotPasswordDialog,
            child: Text(
              'Forgot Password?',
              style: GoogleFonts.instrumentSans(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: curatoMaroon,
              foregroundColor: AppColors.surface,
              shape: StadiumBorder(),
              elevation: 0,
            ),
            child: _isLoading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.surface, strokeWidth: 2))
              : Text('Sign In', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => context.push('/register'),
          child: Text(
            'New here? Become a Vendor',
            style: GoogleFonts.instrumentSans(
              color: curatoMaroon,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ],
      ),
    );

    if (isMobile) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: formContent,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: _bannerUrl != null
                ? NetworkImage(_bannerUrl!) as ImageProvider
                : const AssetImage('assets/auth.png'),
            fit: BoxFit.fill,
            onError: (exception, stackTrace) {
              debugPrint('Error loading network banner image: $exception');
            },
          ),
        ),
        child: Row(
          children: [
            const Spacer(flex: 65),
            Expanded(
              flex: 35,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: formContent,
                  ),
                ),
              ),
            ),
            const Spacer(flex: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, TextEditingController controller, {bool isPassword = false, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.instrumentSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.instrumentSans(color: AppColors.textLight, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: AppColors.surface,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textLight,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
          ),
        ),
      ],
    );
  }
}
