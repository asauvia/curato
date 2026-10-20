import 'package:flutter/material.dart';
import 'package:curato_user/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconUrl;

  const ServiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.grey[50],
              shape: BoxShape.circle,
            ),
            child: Image.network(iconUrl, width: 32, height: 32, errorBuilder: (context, error, stackTrace) => const Icon(Icons.help_outline)),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.instrumentSans(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.instrumentSans(
              fontSize: 11,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
