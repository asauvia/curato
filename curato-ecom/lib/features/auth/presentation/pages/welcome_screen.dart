import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curato_user/core/constants/app_colors.dart';
import 'package:curato_user/features/auth/domain/models/user_model.dart';

class WelcomeScreen extends StatefulWidget {
  final UserModel user;
  const WelcomeScreen({super.key, required this.user});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
    
    // Auto-redirect to Homepage after a few seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Welcome to Curato,',
                        style: GoogleFonts.instrumentSans(
                          color: AppColors.mutedForeground,
                          fontSize: 24,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.user.name.toUpperCase(),
                        style: GoogleFonts.instrumentSans(
                          color: AppColors.foreground,
                          fontSize: 52,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 2,
                        width: 100,
                        color: AppColors.foreground,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Your account is ready! Explore our curated collections.',
                        style: GoogleFonts.instrumentSans(
                          color: AppColors.mutedForeground,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 36),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                        },
                        icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.white, size: 20),
                        label: const Text(
                          'CONTINUE SHOPPING',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.foreground,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/profile', arguments: widget.user);
                        },
                        child: Text(
                          'Go to My Profile',
                          style: GoogleFonts.instrumentSans(
                            color: AppColors.mutedForeground,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
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
}
