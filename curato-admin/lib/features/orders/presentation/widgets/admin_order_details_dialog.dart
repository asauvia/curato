import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curato_admin/features/orders/application/order_controller.dart';
import 'package:curato_admin/core/services/api_service.dart';
import 'package:curato_admin/core/utils/delivery_challan_helper.dart';
import 'package:curato_admin/core/services/invoice_service.dart';
import 'package:curato_admin/features/orders/presentation/widgets/shipping_label_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/services.dart';

import 'package:curato_admin/core/constants/app_colors.dart';

class AdminOrderDetailsDialog extends StatefulWidget {
  final dynamic order;
  final OrderController controller;

  const AdminOrderDetailsDialog({
    super.key,
    required this.order,
    required this.controller,
  });

  @override
  State<AdminOrderDetailsDialog> createState() =>
      _AdminOrderDetailsDialogState();
}

class _AdminOrderDetailsDialogState extends State<AdminOrderDetailsDialog> {
  String _selectedPickupStatus = 'Pending';
  bool _isUpdating = false;
  bool _isUploadingChallan = false;
  String? _delhiveryChallanUrl;

  @override
  void initState() {
    super.initState();
    _selectedPickupStatus = widget.order['pickupStatus'] ?? 'Pending';
    _delhiveryChallanUrl = widget.order['delhiveryChallanUrl'];
  }

  Future<void> _pickAndUploadChallan() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      setState(() {
        _isUploadingChallan = true;
      });

      List<String> uploadedUrls = [];

      for (var file in result.files) {
        if (file.bytes == null) continue;

        final bytes = file.bytes!;
        final filename = file.name;

        final formData = dio.FormData.fromMap({
          'pdf': dio.MultipartFile.fromBytes(bytes, filename: filename),
        });

        final uploadResponse = await ApiService().dio.post('/upload/pdf', data: formData);
        if (uploadResponse.statusCode == 200 && uploadResponse.data['success'] == true) {
          uploadedUrls.add(uploadResponse.data['url']);
        } else {
          throw 'Failed to upload PDF "$filename" to server';
        }
      }

      if (uploadedUrls.isEmpty) {
        throw 'No files were uploaded successfully';
      }

      final String uploadedUrl = uploadedUrls.join(',');

        final updateResponse = await ApiService().dio.put(
          '/order/delhivery-challan',
          data: {
            'orderId': widget.order['_id'],
            'challanUrl': uploadedUrl,
          },
        );

        if (updateResponse.statusCode == 200 && updateResponse.data['success'] == true) {
          setState(() {
            _delhiveryChallanUrl = uploadedUrl;
          });
          await widget.controller.fetchAllOrders();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Delhivery Challan uploaded successfully!'),
                backgroundColor: AppColors.signal,
              ),
            );
          }
        } else {
          throw 'Failed to update order with challan URL';
        }
    } catch (e) {
      debugPrint('Challan upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading challan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploadingChallan = false;
      });
    }
  }

  Future<void> _updatePickupStatus(
    String newStatus, {
    DateTime? scheduleDate,
  }) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final response = await ApiService().dio.put(
        '/order/pickup-status',
        data: {
          'orderId': widget.order['_id'],
          'pickupStatus': newStatus,
          if (scheduleDate != null)
            'pickupScheduleDate': scheduleDate.toUtc().toIso8601String(),
        },
      );

      if (response.data['success']) {
        setState(() {
          _selectedPickupStatus = newStatus;
        });
        await widget.controller.fetchAllOrders();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pickup status updated to $newStatus successfully!',
              style: GoogleFonts.instrumentSans(
                fontWeight: FontWeight.w600,
                color: AppColors.background,
              ),
            ),
            backgroundColor: AppColors.signal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        throw response.data['message'] ?? 'Failed to update';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating pickup status: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.order['status'] ?? 'Pending';
    final isEscalated = widget.order['isEscalated'] ?? false;
    final pd = widget.order['pickupDetails'];
    final dimensions = pd != null ? pd['dimensions'] : null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: AppColors.background,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: 900,
        height: 720,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // Gorgeous Premium Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.foreground, AppColors.foreground],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.mutedForeground.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.mutedForeground.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: AppColors.foreground,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Admin Order Inspection',
                              style: GoogleFonts.instrumentSans(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.background,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.foreground.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.background.withOpacity(0.25),
                                ),
                              ),
                              child: Text(
                                widget.order['orderId'] ?? 'ID',
                                style: GoogleFonts.instrumentSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.border,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fulfillment Vendor: ${widget.order['vendor'] != null ? (widget.order['vendor']['storeName'] ?? widget.order['vendor']['name']) : "Master Admin"}',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 13,
                            color: AppColors.mutedForeground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // const SizedBox(width: 16),
                  // ElevatedButton.icon(
                  //   onPressed: () => InvoiceService.generateAndDownloadInvoice(Map<String, dynamic>.from(widget.order)),
                  //   icon: const Icon(Icons.download, size: 16),
                  //   label: const Text('Download Invoice'),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: AppColors.mutedForeground,
                  //     foregroundColor: AppColors.background,
                  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  //     shape: StadiumBorder(),
                  //   ),
                  // ),
                  if (widget.order['vendorInvoiceUrl'] != null && widget.order['vendorInvoiceUrl'].toString().isNotEmpty) ...[
                    ElevatedButton.icon(
                      onPressed: () async {
                        final url = Uri.parse(widget.order['vendorInvoiceUrl']);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not open vendor invoice URL')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.receipt, size: 16),
                      label: const Text('Vendor Invoice'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.signal,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: StadiumBorder(),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  OutlinedButton.icon(
                    onPressed: () => DeliveryChallanHelper.generateAndDownload(
                      context,
                      Map<String, dynamic>.from(widget.order),
                    ),
                    icon: const Icon(Icons.receipt_long, size: 16),
                    label: const Text('Download Challan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.background,
                      side: BorderSide(color: AppColors.background.withOpacity(0.54)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: StadiumBorder(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: AppColors.background.withOpacity(0.6)),
                    hoverColor: AppColors.background.withOpacity(0.1),
                  ),
                ],
              ),
            ),

            // Dialog Main Body
            Expanded(
              child: Row(
                children: [
                  // Left Side: Order details, Escalations & Customer Details
                  Expanded(
                    flex: 4,
                    child: Container(
                      color: AppColors.muted,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isEscalated) ...[
                              _buildEscalationBanner(),
                              const SizedBox(height: 24),
                            ],

                            // Customer Card
                            Text(
                              'Customer & Shipping Address',
                              style: GoogleFonts.instrumentSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.foreground,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildCustomerCard(),
                            const SizedBox(height: 24),
                            Text(
                              'Order Items',
                              style: GoogleFonts.instrumentSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.foreground,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildOrderItemsSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1, color: AppColors.border),

                  // Right Side: Vendor Pickup details, image, & dropdown status updates
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Vendor Specs & Photo',
                                style: GoogleFonts.instrumentSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.foreground,
                                ),
                              ),
                              _buildStatusTag(_selectedPickupStatus),
                            ],
                          ),
                          const SizedBox(height: 20),

                          if (pd == null) ...[
                            _buildEmptyPickupState(),
                          ] else ...[
                            // Pickup Details Card
                            _buildPickupDetailsCard(pd, dimensions),
                            const SizedBox(height: 24),

                            // Image Verification Card
                            Text(
                              'Verification Photos',
                              style: GoogleFonts.instrumentSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.foreground,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildImageVerification(
                                        widget.order['shippingPhoto'],
                                        "Package Shipping Photo",
                                      ),
                                    ),
                                    if (widget.order['dispatchPhoto'] !=
                                        null) ...[
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildImageVerification(
                                          widget.order['dispatchPhoto'],
                                          "Parcel Sent Verification",
                                        ),
                                      ),
                                    ],
                                    if (widget.order['pickedUpPhoto'] !=
                                        null) ...[
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildImageVerification(
                                          widget.order['pickedUpPhoto'],
                                          "Picked Up Proof",
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            if (status.toUpperCase() != 'DELIVERED' &&
                                status.toUpperCase() != 'CANCELLED') ...[
                              const Divider(color: AppColors.border),
                              const SizedBox(height: 20),

                              // Manual Pickup Coordination
                              Text(
                                'Arrange Pickup (Status Update)',
                                style: GoogleFonts.instrumentSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.foreground,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildStatusUpdater(),
                            ],
                            const Divider(color: AppColors.border),
                            const SizedBox(height: 20),
                            Text(
                              'Delhivery Challan (PDF)',
                              style: GoogleFonts.instrumentSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.foreground,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildDelhiveryChallanSection(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEscalationBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFCA5A5).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'DELIVERY WINDOW EXPIRED',
                style: GoogleFonts.instrumentSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: const Color(0xFF991B1B),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'This order was automatically escalated due to vendor non-confirmation within the 2-day delivery confirmation window.',
            style: GoogleFonts.instrumentSans(
              fontSize: 12.5,
              height: 1.4,
              color: const Color(0xFF7F1D1D),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFEE2E2)),
            ),
            child: Column(
              children: [
                _buildEscalationTimeRow(
                  'Delivered At',
                  widget.order['deliveredAt'],
                ),
                const SizedBox(height: 6),
                _buildEscalationTimeRow(
                  'Escalated At',
                  widget.order['escalatedAt'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEscalationTimeRow(String label, dynamic value) {
    String dateStr = '-';
    if (value != null) {
      dateStr = DateTime.parse(
        value.toString(),
      ).toLocal().toString().split('.')[0];
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.instrumentSans(
            fontSize: 12,
            color: const Color(0xFF991B1B),
          ),
        ),
        Text(
          dateStr,
          style: GoogleFonts.instrumentSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF7F1D1D),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.foreground.withOpacity(0.1),
                child: Text(
                  widget.order['user'] != null
                      ? widget.order['user']['name']
                            .substring(0, 1)
                            .toUpperCase()
                      : 'G',
                  style: GoogleFonts.instrumentSans(
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.order['user'] != null
                          ? widget.order['user']['name']
                          : 'Guest Customer',
                      style: GoogleFonts.instrumentSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.order['user'] != null
                          ? widget.order['user']['email']
                          : '-',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 12,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.phone, size: 16, color: AppColors.mutedForeground),
              const SizedBox(width: 10),
              Text(
                widget.order['user'] != null
                    ? widget.order['user']['mobile']
                    : '-',
                style: GoogleFonts.instrumentSans(
                  fontSize: 13,
                  color: AppColors.foreground,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2.0),
                child: Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  [
                            widget.order['shippingAddress']?['buildingName'],
                            widget.order['shippingAddress']?['street'],
                            widget.order['shippingAddress']?['area'],
                            widget.order['shippingAddress']?['landmark'],
                            widget.order['shippingAddress']?['city'],
                            widget.order['shippingAddress']?['state'],
                          ]
                          .where(
                            (e) => e != null && e.toString().trim().isNotEmpty,
                          )
                          .toSet()
                          .join(', ') +
                      (widget.order['shippingAddress']?['zipCode'] != null &&
                              widget.order['shippingAddress']!['zipCode']
                                  .toString()
                                  .isNotEmpty
                          ? ' - ${widget.order['shippingAddress']?['zipCode']}'
                          : ''),
                  style: GoogleFonts.instrumentSans(
                    fontSize: 13,
                    color: AppColors.foreground,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color bg = AppColors.muted;
    Color fg = AppColors.mutedForeground;

    if (status == 'Pickup Requested') {
      bg = AppColors.muted;
      fg = AppColors.foreground;
    } else if (status == 'Pickup Scheduled') {
      bg = AppColors.muted;
      fg = AppColors.foreground;
    } else if (status == 'Picked Up') {
      bg = AppColors.signalTint;
      fg = AppColors.signal;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: GoogleFonts.instrumentSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPickupState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 40, color: AppColors.mutedForeground),
          const SizedBox(height: 12),
          Text(
            'Specs Pending',
            style: GoogleFonts.instrumentSans(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'The vendor has not submitted parcel details for pickup yet.',
            style: GoogleFonts.instrumentSans(
              fontSize: 12,
              color: AppColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPickupDetailsCard(dynamic pd, dynamic dimensions) {
    String scheduledDateStr = '-';
    if (widget.order['pickupScheduledAt'] != null) {
      scheduledDateStr = DateTime.parse(
        widget.order['pickupScheduledAt'].toString(),
      ).toLocal().toString().split('.')[0];
    }

    String choiceDateStr = '-';
    if (widget.order['pickupScheduleDate'] != null) {
      choiceDateStr = DateTime.parse(
        widget.order['pickupScheduleDate'].toString(),
      ).toLocal().toString().split('.')[0];
    }

    String pickedUpDateStr = '-';
    if (widget.order['pickedUpAt'] != null) {
      pickedUpDateStr = DateTime.parse(
        widget.order['pickedUpAt'].toString(),
      ).toLocal().toString().split('.')[0];
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildSpecsRow(
            'Parcel Weight',
            '${pd['weight'] ?? 0} kg',
            Icons.scale_outlined,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Divider(height: 1, color: AppColors.border),
          ),
          _buildSpecsRow(
            'Number of Parcels',
            '${pd['numberOfParcels'] ?? 1}',
            Icons.inventory_2_outlined,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Divider(height: 1, color: AppColors.border),
          ),
          if (pd['dimensionsList'] != null &&
              (pd['dimensionsList'] as List).isNotEmpty) ...[
            ...(pd['dimensionsList'] as List).asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final d = entry.value;
              return Column(
                children: [
                  _buildSpecsRow(
                    'Parcel #$idx Dimensions (L x W x H)',
                    '${d['length'] ?? 0} × ${d['width'] ?? 0} × ${d['height'] ?? 0} cm',
                    Icons.square_foot_outlined,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
                ],
              );
            }),
          ] else ...[
            _buildSpecsRow(
              'Dimensions (L x W x H)',
              '${dimensions != null ? dimensions['length'] : 0} × ${dimensions != null ? dimensions['width'] : 0} × ${dimensions != null ? dimensions['height'] : 0} cm',
              Icons.square_foot_outlined,
            ),
          ],
          if (widget.order['pickupScheduleDate'] != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Divider(height: 1, color: AppColors.border),
            ),
            _buildSpecsRow(
              'Manual Scheduled Date/Time',
              choiceDateStr,
              Icons.calendar_month_outlined,
            ),
          ] else if (widget.order['pickupScheduledAt'] != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Divider(height: 1, color: AppColors.border),
            ),
            _buildSpecsRow(
              'Pickup Scheduled At',
              scheduledDateStr,
              Icons.calendar_today_outlined,
            ),
          ],
          if (widget.order['pickedUpAt'] != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Divider(height: 1, color: AppColors.border),
            ),
            _buildSpecsRow(
              'Picked Up At',
              pickedUpDateStr,
              Icons.task_alt_outlined,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecsRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.muted,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.mutedForeground),
        ),
        const SizedBox(width: 14),
        Text(
          label,
          style: GoogleFonts.instrumentSans(
            fontSize: 13,
            color: AppColors.mutedForeground,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.instrumentSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.foreground,
          ),
        ),
      ],
    );
  }

  Widget _buildImageVerification(String? photoUrl, String label) {
    if (photoUrl == null) {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.muted,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_not_supported_outlined,
              size: 28,
              color: AppColors.mutedForeground,
            ),
            const SizedBox(height: 8),
            Text(
              'No photo',
              style: GoogleFonts.instrumentSans(
                fontSize: 11,
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Image.network(
              photoUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.foreground.withOpacity(0.8), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.signal,
                      size: 12,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        label,
                        style: GoogleFonts.instrumentSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.background,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusUpdater() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPickupStatus,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.mutedForeground,
                  ),
                  isExpanded: true,
                  style: GoogleFonts.instrumentSans(
                    fontSize: 13,
                    color: AppColors.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                  items:
                      [
                            'Pending',
                            'Pickup Requested',
                            'Pickup Scheduled',
                            'Picked Up',
                          ]
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                  onChanged: _isUpdating
                      ? null
                      : (val) async {
                          if (val != null) {
                            if (val == "Pickup Scheduled") {
                              final DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now().subtract(
                                  const Duration(days: 1),
                                ),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 60),
                                ),
                              );
                              if (date == null) return;

                              final selectedDateTime = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                12, // Default to 12:00 PM (midday)
                                0,
                              );

                              _updatePickupStatus(
                                val,
                                scheduleDate: selectedDateTime,
                              );
                            } else {
                              _updatePickupStatus(val);
                            }
                          }
                        },
                ),
              ),
            ),
          ),
          if (_isUpdating) ...[
            const SizedBox(width: 14),
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.foreground,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItemsSection() {
    final items = List<dynamic>.from(widget.order['items'] ?? []);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    item['image'] ?? 'https://via.placeholder.com/50',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.muted,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.shopping_bag, color: AppColors.mutedForeground),
                    ),
                  ),
                ),
                title: Text(
                  item['name'] ?? 'Product',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Builder(
                  builder: (context) {
                    final prod = item['product'];
                    final varObj = item['variation'];
                    String sku = '-';
                    if (varObj is Map &&
                        varObj['sku'] != null &&
                        varObj['sku'].toString().trim().isNotEmpty) {
                      sku = varObj['sku'].toString();
                    } else if (prod is Map &&
                        prod['sku'] != null &&
                        prod['sku'].toString().trim().isNotEmpty) {
                      sku = prod['sku'].toString();
                    }
                    return Text(
                      'Qty: ${item['quantity']} • SKU: $sku',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 12,
                        color: AppColors.mutedForeground,
                      ),
                    );
                  },
                ),
                trailing: Text(
                  '₹${((item['sellingPrice'] ?? item['price'] ?? 0) * (item['quantity'] ?? 1))}',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 12,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    Text(
                      '₹${widget.order['subtotal'] ?? 0}',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Tax (GST)',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 12,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    Text(
                      '₹${widget.order['totalGst'] ?? 0}',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Grand Total',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${widget.order['totalAmount'] ?? 0}',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ));
      }
  Widget _buildDelhiveryChallanSection() {
    if (_isUploadingChallan) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.foreground),
            ),
            SizedBox(width: 12),
            Text('Uploading PDF...', style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
          ],
        ),
      );
    }

    final hasChallan = _delhiveryChallanUrl != null && _delhiveryChallanUrl!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.picture_as_pdf,
                color: hasChallan ? Colors.red.shade700 : AppColors.mutedForeground,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasChallan ? 'Delhivery Challan PDF' : 'No Challan Uploaded',
                      style: GoogleFonts.instrumentSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasChallan ? 'Available for vendor to download' : 'Upload official challan PDF',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 12,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (hasChallan) ...[
                ..._delhiveryChallanUrl!.split(',').asMap().entries.map((entry) {
                  final index = entry.key;
                  final singleUrl = entry.value.trim();
                  final challanList = _delhiveryChallanUrl!.split(',');
                  final label = challanList.length == 1 ? 'View' : 'View ${index + 1}';
                  return TextButton.icon(
                    onPressed: () async {
                      final url = Uri.parse(singleUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not open Challan URL')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: Text(label),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.mutedForeground,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  );
                }),
              ],
              ElevatedButton.icon(
                onPressed: _pickAndUploadChallan,
                icon: Icon(hasChallan ? Icons.cached : Icons.upload_file, size: 16),
                label: Text(hasChallan ? 'Change' : 'Upload'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasChallan ? AppColors.border : AppColors.mutedForeground,
                  foregroundColor: hasChallan ? AppColors.foreground : AppColors.background,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: StadiumBorder(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
