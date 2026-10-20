import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curato_user/core/constants/app_colors.dart';
import 'package:curato_user/features/auth/application/address_controller.dart';
import 'package:curato_user/features/auth/domain/models/address_model.dart';
import 'package:curato_user/features/cart/presentation/widgets/address_form_dialog.dart';

class AddressItemTile extends StatelessWidget {
  final AddressModel address;
  final bool isSelected;
  final VoidCallback onSelect;
  final AddressController addressController;

  const AddressItemTile({
    super.key,
    required this.address,
    required this.isSelected,
    required this.onSelect,
    required this.addressController,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : AppColors.muted,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.foreground : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: isSelected ? AppColors.foreground : AppColors.grey[400],
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  address.name,
                  style: GoogleFonts.instrumentSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.foreground.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'HOME',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.mobile,
                    style: GoogleFonts.instrumentSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.fullAddress,
                    style: GoogleFonts.instrumentSans(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  if (address.gstNumber != null || address.panNumber != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (address.gstNumber != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.muted,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.business_outlined, size: 12, color: AppColors.foreground),
                                const SizedBox(width: 4),
                                Text(
                                  'GST: ${address.gstNumber}',
                                  style: GoogleFonts.instrumentSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.foreground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (address.gstNumber != null && address.panNumber != null)
                          const SizedBox(width: 8),
                        if (address.panNumber != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.foreground,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.foreground),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.credit_card_outlined, size: 12, color: AppColors.foreground),
                                const SizedBox(width: 4),
                                Text(
                                  'PAN: ${address.panNumber}',
                                  style: GoogleFonts.instrumentSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.foreground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (isSelected) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildAddressActionButton(
                          context: context,
                          icon: Icons.edit_outlined,
                          label: 'EDIT',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddressFormDialog(address: address),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        _buildAddressActionButton(
                          context: context,
                          icon: Icons.delete_outline_rounded,
                          label: 'DELETE',
                          isDelete: true,
                          onPressed: () {
                            _showDeleteConfirmation(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          padding: const EdgeInsets.all(32),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorRed[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_outline_rounded, color: AppColors.errorRed[400], size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                'Delete Address?',
                style: GoogleFonts.instrumentSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to remove this delivery address? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: GoogleFonts.instrumentSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'CANCEL',
                        style: GoogleFonts.instrumentSans(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await addressController.deleteAddress(address.id!);
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorRed[400],
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: Text(
                        'DELETE',
                        style: GoogleFonts.instrumentSans(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isDelete = false,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isDelete ? AppColors.errorRed[400] : AppColors.foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.instrumentSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDelete ? AppColors.errorRed[400] : AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
