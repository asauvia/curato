import 'package:curato_user/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curato_user/core/widgets/shell_screen.dart';
import 'package:curato_user/core/utils/responsive.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';
import '../widgets/forgot_password_form.dart';

class AuthScreen extends StatefulWidget {
  final bool isInitialLogin;
  const AuthScreen({super.key, required this.isInitialLogin});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum AuthMode { login, register, forgotPassword }

class _AuthScreenState extends State<AuthScreen> {
  late AuthMode _authMode;

  @override
  void initState() {
    super.initState();
    _authMode = widget.isInitialLogin ? AuthMode.login : AuthMode.register;
  }

  void _toggleAuth() {
    setState(() {
      if (_authMode == AuthMode.login) {
        _authMode = AuthMode.register;
      } else {
        _authMode = AuthMode.login;
      }
    });
  }

  void _showForgotPassword() {
    setState(() {
      _authMode = AuthMode.forgotPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return ShellScreen(
      child: Container(
        color: AppColors.bgSecondaryLight,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top Logo Area
                // _buildLogo(),
                // const SizedBox(height: 24),

                // Card Container
                Container(
                  width: isMobile ? double.infinity : 480,
                  constraints: const BoxConstraints(maxWidth: 480),
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 40, vertical: 32),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildCurrentForm(),
                  ),
                ),
                
                const SizedBox(height: 40),
                Text(
                  'By creating an account, you agree to our terms and conditions',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.instrumentSans(color: AppColors.mutedForeground, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentForm() {
    switch (_authMode) {
      case AuthMode.login:
        return LoginForm(
          key: const ValueKey('login'),
          onToggle: _toggleAuth,
          onForgotPassword: _showForgotPassword,
        );
      case AuthMode.register:
        return RegisterForm(
          key: const ValueKey('register'),
          onToggle: _toggleAuth,
        );
      case AuthMode.forgotPassword:
        return ForgotPasswordForm(
          key: const ValueKey('forgot_password'),
          onBackToLogin: () {
            setState(() {
              _authMode = AuthMode.login;
            });
          },
        );
    }
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.foreground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text(
              'O',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'curato',
              style: GoogleFonts.instrumentSans(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.5,
                color: AppColors.foreground,
              ),
            ),
            Text(
              'SHOP SMART',
              style: GoogleFonts.instrumentSans(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
    
      ],
    );
  }
}
