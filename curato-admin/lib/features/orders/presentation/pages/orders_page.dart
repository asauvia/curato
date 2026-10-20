import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:curato_admin/features/layout/presentation/widgets/admin_layout.dart';

import 'package:curato_admin/features/orders/application/order_controller.dart';

import 'package:curato_admin/core/services/global_search_service.dart';
import 'package:curato_admin/core/services/service_locator.dart';
import 'package:curato_admin/features/orders/presentation/widgets/edit_invoice_dialog.dart';
import 'package:curato_admin/features/orders/presentation/widgets/shipping_label_dialog.dart';
import 'package:curato_admin/features/orders/presentation/widgets/assign_delhivery_dialog.dart';
import 'package:curato_admin/features/orders/presentation/widgets/manual_tracking_dialog.dart';
import 'package:curato_admin/features/orders/presentation/widgets/admin_order_details_dialog.dart';

import 'package:curato_admin/core/constants/app_colors.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final OrderController _controller = OrderController();
  final GlobalSearchService _globalSearchService = sl<GlobalSearchService>();
  String _selectedStatus = 'All Status';
  final String _selectedPayment = 'All Payments';
  String _searchQuery = '';

  final List<String> _statusOptions = [
    'All Status',
    'Pending',
    'Processing',
    'Ready to Dispatch',
    'Shipment Requested',
    'Shipment Scheduled',
    'Shipped',
    'Delivered',
    'Cancelled',
    'Escalated',
  ];

  String _getEffectiveStatus(Map<String, dynamic> o) {
    final String rawStatus = o['status'] ?? 'Pending';
    final String pickupStatus = o['pickupStatus'] ?? 'Pending';
    String effectiveStatus = rawStatus;
    if (rawStatus.toUpperCase() == 'READY_TO_DISPATCH') {
      return 'READY TO DISPATCH';
    }
    if (!['SHIPPED', 'OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED', 'ESCALATED'].contains(rawStatus.toUpperCase())) {
      if (pickupStatus == 'Pickup Requested') {
        effectiveStatus = 'SHIPMENT REQUESTED';
      } else if (pickupStatus == 'Pickup Scheduled') {
        effectiveStatus = 'SHIPMENT SCHEDULED';
      } else if (pickupStatus == 'Picked Up') {
        effectiveStatus = 'PICKED UP';
      }
    }
    return effectiveStatus;
  }
  final List<String> _paymentOptions = ['All Payments', 'Paid', 'Unpaid', 'Refunded'];

  @override
  void initState() {
    super.initState();
    _controller.fetchAllOrders();
    _globalSearchService.searchQuery.addListener(_onGlobalSearchChanged);
  }

  @override
  void dispose() {
    _globalSearchService.searchQuery.removeListener(_onGlobalSearchChanged);
    super.dispose();
  }

  void _onGlobalSearchChanged() {
    setState(() {
      _searchQuery = _globalSearchService.searchQuery.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/orders',
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final orders = _controller.orders.where((o) {
            bool matchesStatus = _selectedStatus == 'All Status' || (() {
              final String eff = _getEffectiveStatus(o).toUpperCase();
              final String selected = _selectedStatus.toUpperCase();
              if (selected == 'PENDING') {
                return eff == 'PENDING' || eff == 'CREATED';
              } else if (selected == 'SHIPPED') {
                return eff == 'SHIPPED' || eff == 'SHIPMENT SCHEDULED';
              } else if (selected == 'READY TO DISPATCH' || selected == 'READY_TO_DISPATCH') {
                return eff == 'READY TO DISPATCH' || eff == 'READY_TO_DISPATCH';
              }
              return eff == selected;
            }());
            bool matchesSearch = _searchQuery.isEmpty || 
                (o['orderId']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                (o['user']?['name']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
            return matchesStatus && matchesSearch;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumb
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                color: AppColors.background,
                child: Row(
                  children: [
                    Text('Master Admin', style: GoogleFonts.instrumentSans(color: AppColors.mutedForeground, fontSize: 13)),
                    const Icon(Icons.chevron_right, size: 18, color: AppColors.mutedForeground),
                    Text('Admin Orders', style: GoogleFonts.instrumentSans(color: AppColors.mutedForeground, fontSize: 13)),
                  ],
                ),
              ),

              if (_controller.isLoading)
                const LinearProgressIndicator(color: AppColors.foreground, minHeight: 2),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Orders Management',
                                style: GoogleFonts.instrumentSans(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.5,
                                  color: AppColors.foreground,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Manage and track all customer orders',
                                style: GoogleFonts.instrumentSans(color: AppColors.mutedForeground, fontSize: 14),
                              ),
                            ],
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _controller.fetchAllOrders(),
                            icon: const Icon(Icons.refresh, size: 16),
                            label: Text('Refresh', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w500)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: StadiumBorder(),
                              side: BorderSide(color: AppColors.border),
                              foregroundColor: AppColors.foreground,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Filters
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            // Search
                            Expanded(
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.muted,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  children: [
                                    Icon(Icons.search, color: AppColors.mutedForeground, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        onChanged: (v) => setState(() => _searchQuery = v),
                                        decoration: InputDecoration(
                                          hintText: 'Search by order number or customer name...',
                                          hintStyle: GoogleFonts.instrumentSans(color: AppColors.mutedForeground, fontSize: 13),
                                          border: InputBorder.none,
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Status Dropdown
                            _buildDropdown(
                              value: _selectedStatus,
                              items: _statusOptions,
                              onChanged: (v) => setState(() => _selectedStatus = v!),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () async {
                                await _controller.requestNotificationPermission();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Web Notifications configured!'), backgroundColor: AppColors.foreground),
                                  );
                                }
                              },
                              icon: const Icon(Icons.notifications_active, size: 16),
                              label: const Text('Enable Notifications'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.foreground,
                                foregroundColor: AppColors.background,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                shape: StadiumBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Table
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            // Table Header
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: AppColors.border)),
                                color: AppColors.muted,
                              ),
                              child: Row(
                                children: [
                                  _tableHeader('ORDER ID', flex: 2),
                                  _tableHeader('CUSTOMER', flex: 2),
                                  _tableHeader('VENDOR', flex: 2),
                                  _tableHeader('ITEMS', flex: 1),
                                  _tableHeader('TOTAL', flex: 1),
                                  _tableHeader('STATUS', flex: 3),
                                  _tableHeader('AWB', flex: 2),
                                  _tableHeader('DATE', flex: 2),
                                  _tableHeader('ACTIONS', flex: 4),
                                ],
                              ),
                            ),

                            if (orders.isEmpty)
                              _buildEmptyState()
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: orders.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final o = orders[index];
                                  debugPrint('--- Admin/Vendor Order [${o['orderId']}] Tracking URL: ${o['trackingUrl']} ---');
                                  final String oId = o['orderId'] ?? 'ID';
                                  final String customer = o['user'] != null ? o['user']['name'] : 'Guest';
                                  final String vendor = o['vendor'] != null ? (o['vendor']['storeName'] ?? o['vendor']['name']) : 'Admin';
                                  final List items = o['items'] ?? [];
                                  final double total = (o['totalAmount'] ?? 0).toDouble();
                                  final String status = o['status'] ?? 'Pending';
                                  final String effectiveStatus = _getEffectiveStatus(o);
                                  final String date = o['createdAt'] != null ? DateTime.parse(o['createdAt'].toString()).toString().split(' ')[0] : '-';

                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 15,
                                          child: InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AdminOrderDetailsDialog(order: o, controller: _controller),
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Expanded(flex: 2, child: Text(oId, style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w600))),
                                                Expanded(flex: 2, child: Text(customer, style: GoogleFonts.instrumentSans(fontSize: 13))),
                                                Expanded(flex: 2, child: Text(vendor, style: GoogleFonts.instrumentSans(fontSize: 13, color: AppColors.foreground))),
                                                Expanded(flex: 1, child: Text('${items.length}', style: GoogleFonts.instrumentSans(fontSize: 13))),
                                                Expanded(flex: 1, child: Text('₹$total', style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.bold))),
                                                Expanded(flex: 3, child: _buildStatusBadge(effectiveStatus)),
                                                Expanded(
                                                  flex: 2, 
                                                  child: Text(
                                                    o['awb'] ?? '-', 
                                                    style: GoogleFonts.instrumentSans(fontSize: 12, color: AppColors.foreground, fontWeight: FontWeight.bold),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Expanded(flex: 2, child: Text(date, style: GoogleFonts.instrumentSans(fontSize: 13))),
                                              ],
                                            ),
                                          ),
                                        ),
                                          Expanded(
                                            flex: 4, 
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => EditInvoiceDialog(order: o),
                                                      );
                                                    },
                                                    icon: const Icon(
                                                      Icons.download_for_offline, 
                                                      size: 20, 
                                                      color: AppColors.foreground,
                                                    ),
                                                    tooltip: 'Download Invoice',
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(),
                                                  ),
                                                  if (o['vendorInvoiceUrl'] != null && o['vendorInvoiceUrl'].toString().isNotEmpty) ...[
                                                    const SizedBox(width: 8),
                                                    IconButton(
                                                      onPressed: () async {
                                                        final url = Uri.parse(o['vendorInvoiceUrl']);
                                                        if (await canLaunchUrl(url)) {
                                                          await launchUrl(url, mode: LaunchMode.externalApplication);
                                                        } else {
                                                          if (context.mounted) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              const SnackBar(content: Text('Could not open vendor invoice URL')),
                                                            );
                                                          }
                                                        }
                                                      },
                                                      icon: const Icon(
                                                        Icons.receipt, 
                                                        size: 20, 
                                                        color: AppColors.signal,
                                                      ),
                                                      tooltip: 'Download Vendor Invoice',
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints(),
                                                    ),
                                                  ],
                                                const SizedBox(width: 8),
                                                IconButton(
                                                  onPressed: (status.toLowerCase() != 'cancelled' && 
                                                              status.toLowerCase() != 'pending')
                                                    ? () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => ShippingLabelDialog(order: o),
                                                      );
                                                    }
                                                    : null,
                                                  icon: Icon(
                                                    Icons.local_shipping_outlined, 
                                                    size: 20, 
                                                    color: (status.toLowerCase() != 'cancelled' && 
                                                            status.toLowerCase() != 'pending')
                                                        ? AppColors.foreground
                                                        : AppColors.mutedForeground.withOpacity(0.3),
                                                  ),
                                                  tooltip: 'Download Shipping Label',
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                ),
                                                const SizedBox(width: 8),
                                                IconButton(
                                                  onPressed: (status.toLowerCase() == 'pending' || status.toLowerCase() == 'processing')
                                                      ? () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (dialogContext) => AssignDelhiveryDialog(
                                                              order: o,
                                                              onConfirm: (data) async {
                                                                final result = await _controller.assignDelhivery(o['_id'], data: data);
                                                                if (!mounted) return;
                                                                final isSuccess = result['success'] == true;
                                                                final message = result['message'] ?? (isSuccess ? 'Delivery assigned successfully!' : 'Failed to assign delivery.');
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(message),
                                                                    backgroundColor: isSuccess ? AppColors.signal : Colors.red,
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        }
                                                      : null,
                                                  icon: Icon(
                                                    Icons.local_shipping, 
                                                    size: 20, 
                                                    color: (status.toLowerCase() == 'pending' || status.toLowerCase() == 'processing')
                                                        ? AppColors.foreground
                                                        : AppColors.mutedForeground.withOpacity(0.3),
                                                  ),
                                                  tooltip: 'Assign Delhivery',
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                ),
                                                const SizedBox(width: 8),
                                                IconButton(
                                                  onPressed: (status.toLowerCase() != 'cancelled')
                                                      ? () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) => ManualTrackingDialog(
                                                              order: o,
                                                              onConfirm: (trackingInfo) async {
                                                                final success = await _controller.updateOrderTracking(o['_id'], trackingInfo);
                                                                if (!mounted) return;
                                                                if (success) {
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    const SnackBar(content: Text('Tracking info updated!'), backgroundColor: AppColors.signal),
                                                                  );
                                                                } else {
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    const SnackBar(content: Text('Failed to update tracking info'), backgroundColor: Colors.red),
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          );
                                                        }
                                                      : null,
                                                  icon: Icon(
                                                    Icons.edit_location_alt_outlined, 
                                                    size: 20, 
                                                    color: (status.toLowerCase() != 'cancelled')
                                                        ? AppColors.foreground
                                                        : AppColors.mutedForeground.withOpacity(0.3),
                                                  ),
                                                  tooltip: 'Manual Tracking Update',
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                ),
                                                const SizedBox(width: 8),
                                                if (o['trackingUrl'] != null && o['trackingUrl'].toString().isNotEmpty)
                                                  IconButton(
                                                    icon: const Icon(Icons.open_in_new, size: 20, color: AppColors.foreground),
                                                    tooltip: 'Track Package',
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(),
                                                    onPressed: () async {
                                                      final url = Uri.parse(o['trackingUrl']);
                                                      try {
                                                        await launchUrl(url, mode: LaunchMode.externalApplication);
                                                      } catch (e) {
                                                        debugPrint('Error launching URL: $e');
                                                      }
                                                    },
                                                  ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      width: double.infinity,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: AppColors.muted, shape: BoxShape.circle),
            child: Icon(Icons.shopping_bag_outlined, color: AppColors.border, size: 32),
          ),
          const SizedBox(height: 20),
          Text('No orders found', style: GoogleFonts.instrumentSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
          const SizedBox(height: 6),
          Text('Try adjusting your filters', style: GoogleFonts.instrumentSans(color: AppColors.mutedForeground, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = AppColors.mutedForeground;
    final s = status.toUpperCase();
    if (s == 'DELIVERED') {
      color = AppColors.signal;
    } else if (s == 'CANCELLED' || s == 'ESCALATED') {
      color = Colors.red;
    } else if (const {
      'SHIPPED',
      'OUT_FOR_DELIVERY',
      'PROCESSING',
      'SHIPMENT REQUESTED',
      'PICKUP REQUESTED',
      'SHIPMENT SCHEDULED',
      'PICKUP SCHEDULED',
      'PICKED UP',
      'READY TO DISPATCH',
      'READY_TO_DISPATCH',
    }.contains(s)) {
      color = AppColors.foreground;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                status.toUpperCase(),
                style: GoogleFonts.instrumentSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.mutedForeground),
          style: GoogleFonts.instrumentSans(fontSize: 13, color: AppColors.foreground),
          items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _tableHeader(String title, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.mutedForeground,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
