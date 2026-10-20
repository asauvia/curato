import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curato_vendor/core/constants/app_colors.dart';

class SidebarLayout extends StatelessWidget {
  final Widget child;
  final String activeRoute;

  const SidebarLayout({
    super.key,
    required this.child,
    this.activeRoute = '/',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(right: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo Section
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'O',
                          style: TextStyle(
                            color: AppColors.surface,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'CURATO',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w400, letterSpacing: -0.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu Section
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildSectionHeader('MENU'),
                      _buildNavItem(context, Icons.dashboard_outlined, 'Dashboard', route: '/'),
                      _buildNavItem(context, Icons.shopping_cart_outlined, 'Order', route: '/orders'),
                      // _buildNavItem(context, Icons.people_outline, 'Customers', route: '/customers'),
                      const SizedBox(height: 24),

                      _buildSectionHeader('TOOLS'),
                      _buildNavItem(context, Icons.inventory_2_outlined, 'Product', route: '/products'),
                      _buildNavItem(context, Icons.category_outlined, 'Categories', route: '/categories'),
                      _buildNavItem(context, Icons.account_tree_outlined, 'Sub Categories', route: '/subcategories'),
                      _buildNavItem(context, Icons.percent_outlined, 'Discount', route: '/discounts'),
                      // _buildNavItem(context, Icons.grid_view_outlined, 'Integrations', route: '/integrations'),
                      _buildNavItem(context, Icons.analytics_outlined, 'Analytic', route: '/analytics'),
                      _buildNavItem(context, Icons.account_balance_wallet_outlined, 'Payouts', route: '/payouts'),
                      const SizedBox(height: 24),

                      _buildNavItem(context, Icons.settings_outlined, 'Settings', route: '/settings'),
                      _buildNavItem(context, Icons.help_outline, 'Get Help', route: '/help'),
                      _buildNavItem(context, Icons.quiz_outlined, 'FAQ', route: '/faq'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content Area
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 16),
      child: Text(
        title,
        style: GoogleFonts.instrumentSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String title, {
    required String route,
  }) {
    final isActive = activeRoute == route;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.muted : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? AppColors.primary : AppColors.textSecondary,
          size: 20,
        ),
        title: Text(
          title,
          style: GoogleFonts.instrumentSans(
            color: isActive ? AppColors.primary : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        dense: true,
        onTap: () {
          if (!isActive) {
            context.go(route);
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
