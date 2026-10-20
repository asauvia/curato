import 'package:curato_user/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:curato_user/features/auth/application/auth_service.dart';
import 'package:curato_user/core/services/session_service.dart';
import 'package:curato_user/features/cart/application/cart_controller.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onToggle;
  final VoidCallback onForgotPassword;
  const LoginForm({super.key, required this.onToggle, required this.onForgotPassword});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final AuthService _authService = AuthService();

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final response = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (response.success) {
        if (mounted) {
          SessionService.instance.setUser(response.user, token: response.token);
          await CartController.instance.loadCart();
          await CartController.instance.processPendingCart();
          Navigator.of(context).pushReplacementNamed('/welcome', arguments: response.user);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message), backgroundColor: AppColors.errorRed),
          );
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
            'Sign In',
            style: GoogleFonts.instrumentSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Welcome back to the premium marketplace',
            style: GoogleFonts.instrumentSans(
              color: AppColors.mutedForeground,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),

          // Fields
          _buildFieldLabel('Email Address'),
          _buildTextField(
            controller: _emailController,
            hintText: 'Enter your email',
            icon: Icons.mail_outline,
            validator: (v) => v!.isEmpty || !v.contains('@') ? 'Invalid email' : null,
          ),
          const SizedBox(height: 12),

          _buildFieldLabel('Password'),
          _buildTextField(
            controller: _passwordController,
            hintText: '*********',
            icon: Icons.lock_outline,
            obscure: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.mutedForeground, size: 18),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) => v!.length < 6 ? 'Password too short' : null,
          ),
          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onForgotPassword,
              child: Text('Forgot Password?', style: GoogleFonts.instrumentSans(color: AppColors.foreground, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 16),

          // Logic Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.foreground,
                foregroundColor: AppColors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Sign In', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.border)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: Text('or', style: GoogleFonts.instrumentSans(color: AppColors.mutedForeground, fontSize: 12))),
              const Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 24),
          
          // Full-width Social Login Buttons using Outline Layout
          _SocialLoginButton(
            icon: FontAwesomeIcons.google,
            text: 'Sign in with Google',
            color: AppColors.errorRed,
            onPressed: () async {
              setState(() => _isLoading = true);
              final response = await _authService.signInWithGoogle();
              setState(() => _isLoading = false);

              if (response.success) {
                if (mounted) {
                  SessionService.instance.setUser(response.user, token: response.token);
                  await CartController.instance.loadCart();
                  await CartController.instance.processPendingCart();
                  Navigator.of(context).pushReplacementNamed('/welcome', arguments: response.user);
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response.message), backgroundColor: AppColors.errorRed),
                  );
                }
              }
            },
          ),
          
          const SizedBox(height: 24),

          // Sign up Link
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Don\'t have an account? ', style: GoogleFonts.instrumentSans(color: AppColors.mutedForeground, fontSize: 14)),
              InkWell(
                onTap: widget.onToggle,
                child: Text('Create Account', style: GoogleFonts.instrumentSans(color: AppColors.foreground, fontSize: 14, fontWeight: FontWeight.bold)),
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
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: GoogleFonts.instrumentSans(color: AppColors.foreground, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.instrumentSans(color: AppColors.mutedForeground, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.mutedForeground, size: 18),
        suffixIcon: suffixIcon,
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

class _SocialLoginButton extends StatelessWidget {
  final dynamic icon;
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.icon,
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          shape: const StadiumBorder(),
          backgroundColor: AppColors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon is IconData
                ? Icon(icon as IconData, color: color, size: 20)
                : FaIcon(icon as FaIconData, color: color, size: 20),
            const SizedBox(width: 15),
            Text(
              text,
              style: GoogleFonts.instrumentSans(
                color: AppColors.foreground,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
