import 'package:curato_user/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curato_user/features/auth/application/auth_service.dart';

class ForgotPasswordForm extends StatefulWidget {
  final VoidCallback onBackToLogin;
  const ForgotPasswordForm({super.key, required this.onBackToLogin});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final response = await _authService.forgotPassword(
        _emailController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: response.success ? AppColors.signal : AppColors.errorRed,
          ),
        );
        if (response.success) {
          widget.onBackToLogin();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Forgot Password',
            style: GoogleFonts.instrumentSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter your email to receive a password reset link',
            textAlign: TextAlign.center,
            style: GoogleFonts.instrumentSans(
              color: AppColors.mutedForeground,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),

          _buildFieldLabel('Email Address'),
          _buildTextField(
            controller: _emailController,
            hintText: 'Enter your email',
            icon: Icons.mail_outline,
            validator: (v) => v!.isEmpty || !v.contains('@') ? 'Invalid email' : null,
          ),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.foreground,
                foregroundColor: AppColors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.foreground, strokeWidth: 2))
                  : Text('Send Reset Link', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 24),

          // Back to Login Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Remember your password? ', style: GoogleFonts.instrumentSans(color: AppColors.mutedForeground, fontSize: 14)),
              InkWell(
                onTap: widget.onBackToLogin,
                child: Text('Sign In', style: GoogleFonts.instrumentSans(color: AppColors.foreground, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.foreground),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: GoogleFonts.instrumentSans(color: AppColors.foreground, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.instrumentSans(color: AppColors.mutedForeground, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.mutedForeground, size: 18),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.foreground),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
      ),
    );
  }
}
