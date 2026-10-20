import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curato_user/core/constants/app_colors.dart';

class CheckoutStepHeader extends StatelessWidget {
  final int step;
  final String title;
  final Widget content;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback? onStepTap;
  final VoidCallback? onChangeTap;

  const CheckoutStepHeader({
    super.key,
    required this.step,
    required this.title,
    required this.content,
    required this.isActive,
    required this.isCompleted,
    this.onStepTap,
    this.onChangeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onStepTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isActive ? AppColors.foreground.withOpacity(0.05) : AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.foreground : AppColors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${step + 1}',
                      style: GoogleFonts.jetBrainsMono(
                        color: isActive ? AppColors.white : AppColors.grey[500],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.instrumentSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isActive ? AppColors.foreground : AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  if (isCompleted && !isActive)
                    const Icon(Icons.check_circle_rounded, color: AppColors.signal, size: 20),
                  if (isCompleted && !isActive)
                    TextButton(
                      onPressed: onChangeTap,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        'CHANGE', 
                        style: GoogleFonts.instrumentSans(
                          color: AppColors.foreground, 
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        )
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isActive) content,
        ],
      ),
    );
  }
}
