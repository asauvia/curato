import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curato_user/core/constants/app_colors.dart';
import 'package:curato_user/features/cart/application/cart_controller.dart';

class PriceDetailsCard extends StatelessWidget {
  final CartController cartController;
  const PriceDetailsCard({super.key, required this.cartController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'PRICE DETAILS',
              style: GoogleFonts.jetBrainsMono(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildPriceRow('Price (${cartController.itemCount} items)', '\u20b9${cartController.subtotal.ceil()}'),
                const SizedBox(height: 16),
                _buildPriceRow('Delivery Charges', 'FREE', valueColor: AppColors.signal),
                const SizedBox(height: 16),
                _buildPriceRow('Taxes', '\u20b9${cartController.tax.ceil()}'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Divider(height: 1, color: AppColors.border),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: GoogleFonts.instrumentSans(
                        fontWeight: FontWeight.bold, 
                        fontSize: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '\u20b9${cartController.totalAmount.ceil()}',
                      style: GoogleFonts.instrumentSans(
                        fontWeight: FontWeight.bold, 
                        fontSize: 22,
                        color: AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.stars_rounded, color: AppColors.signal, size: 18),
                const SizedBox(width: 8),
                Text(
                  'You will save \u20b9${cartController.savings.ceil()} on this order',
                  style: GoogleFonts.instrumentSans(
                    color: AppColors.signal, 
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label, 
          style: GoogleFonts.instrumentSans(
            fontSize: 14,
            color: AppColors.textSecondary,
          )
        ),
        Text(
          value,
          style: GoogleFonts.instrumentSans(
            fontSize: 15,
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: valueColor != null ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
