import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart' as dio_pkg;
import 'package:curato_vendor/core/constants/app_colors.dart';
import 'package:curato_vendor/core/widgets/sidebar_layout.dart';
import 'package:curato_vendor/core/widgets/vendor_topbar.dart';
import 'package:curato_vendor/features/orders/application/order_controller.dart';
import 'package:curato_vendor/features/orders/presentation/widgets/edit_invoice_dialog.dart';
import 'package:curato_vendor/features/orders/presentation/widgets/shipping_label_dialog.dart';
import 'package:curato_vendor/features/orders/presentation/widgets/assign_delhivery_dialog.dart';
import 'package:curato_vendor/features/orders/presentation/widgets/order_details_dialog.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final OrderController _controller = OrderController();
  String _selectedStatus = 'All Status';
  final TextEditingController _searchController = TextEditingController();

  Future<void> _downloadFile(String fileUrl, String fileName) async {
    try {
      if (kIsWeb) {
        final response = await dio_pkg.Dio().get<List<int>>(
          fileUrl,
          options: dio_pkg.Options(responseType: dio_pkg.ResponseType.bytes),
        );
        final bytes = response.data;
        if (bytes != null) {
          final blob = html.Blob([bytes], 'application/pdf');
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: url)
            ..setAttribute('download', fileName)
            ..style.display = 'none';
          html.document.body!.children.add(anchor);
          anchor.click();
          html.document.body!.children.remove(anchor);
          html.Url.revokeObjectUrl(url);
        }
      } else {
        final url = Uri.parse(fileUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      debugPrint('Download error: $e');
      final url = Uri.parse(fileUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }

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

  @override
  void initState() {
    super.initState();
    _controller.fetchVendorOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SidebarLayout(
      activeRoute: '/orders',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const VendorTopBar(),
        body: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final query = _searchController.text.trim().toLowerCase();
            final orders = _controller.orders.where((o) {
               // 1. Status Filter
               if (_selectedStatus != 'All Status') {
                 final String eff = _getEffectiveStatus(o).toUpperCase();
                 final String selected = _selectedStatus.toUpperCase();
                 if (selected == 'PENDING') {
                   if (eff != 'PENDING' && eff != 'CREATED') return false;
                 } else if (selected == 'SHIPPED') {
                   if (eff != 'SHIPPED' && eff != 'SHIPMENT SCHEDULED') return false;
                 } else if (selected == 'READY TO DISPATCH' || selected == 'READY_TO_DISPATCH') {
                   if (eff != 'READY TO DISPATCH' && eff != 'READY_TO_DISPATCH') return false;
                 } else {
                   if (eff != selected) return false;
                 }
               }
               // 2. Search Query Filter
               if (query.isNotEmpty) {
                 final orderId = (o['orderId'] ?? '').toString().toLowerCase();
                 final customerName = (o['user'] != null ? o['user']['name'] ?? '' : '').toString().toLowerCase();
                 final items = o['items'] as List? ?? [];
                 final productNames = items.map((item) => (item['name'] ?? '').toString().toLowerCase()).join(' ');
                 
                 return orderId.contains(query) || customerName.contains(query) || productNames.contains(query);
               }
               return true;
            }).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   if (_controller.isLoading)
                    const LinearProgressIndicator(color: AppColors.primary),
                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Total Orders',
                          value: '${_controller.totalOrders}',
                          dotColor: AppColors.primary,
                          onTap: () => setState(() => _selectedStatus = 'All Status'),
                          isSelected: _selectedStatus == 'All Status',
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _StatCard(
                          label: 'Pending',
                          value: '${_controller.pendingOrders}',
                          dotColor: Colors.amber,
                          onTap: () => setState(() => _selectedStatus = 'Pending'),
                          isSelected: _selectedStatus == 'Pending',
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _StatCard(
                          label: 'Processing',
                          value: '${_controller.processingOrders}',
                          dotColor: Colors.blue,
                          onTap: () => setState(() => _selectedStatus = 'Processing'),
                          isSelected: _selectedStatus == 'Processing',
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _StatCard(
                          label: 'Shipped',
                          value: '${_controller.shippedOrders}',
                          dotColor: Colors.purple,
                          onTap: () => setState(() => _selectedStatus = 'Shipped'),
                          isSelected: _selectedStatus == 'Shipped',
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _StatCard(
                          label: 'Delivered',
                          value: '${_controller.deliveredOrders}',
                          dotColor: Colors.green,
                          onTap: () => setState(() => _selectedStatus = 'Delivered'),
                          isSelected: _selectedStatus == 'Delivered',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Table Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        // Search + Filter Bar
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Search Field
                              SizedBox(
                                width: 260,
                                height: 40,
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (v) => setState(() {}),
                                  style: GoogleFonts.instrumentSans(fontSize: 13),
                                  decoration: InputDecoration(
                                    hintText: 'Search orders...',
                                    hintStyle: GoogleFonts.instrumentSans(
                                      fontSize: 13,
                                      color: AppColors.textLight,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      size: 18,
                                      color: AppColors.textLight,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.surface,
                                  ),
                                ),
                              ),

                              const Spacer(),

                              // Status Dropdown
                              Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(8),
                                  color: AppColors.surface,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedStatus,
                                    icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                                    style: GoogleFonts.instrumentSans(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                    items: _statusOptions.map((s) {
                                      return DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _selectedStatus = val);
                                      }
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Filter Button
                              OutlinedButton.icon(
                                onPressed: () => _controller.fetchVendorOrders(),
                                icon: const Icon(Icons.refresh, size: 16),
                                label: Text(
                                  'Refresh',
                                  style: GoogleFonts.instrumentSans(fontSize: 13),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textPrimary,
                                  side: BorderSide(color: AppColors.border),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  shape: StadiumBorder(),
                               ),
                              ),
                               const SizedBox(width: 12),
                               ElevatedButton.icon(
                                 onPressed: () async {
                                   await _controller.requestNotificationPermission();
                                   if (mounted) {
                                     ScaffoldMessenger.of(context).showSnackBar(
                                       const SnackBar(content: Text('Web Notifications configured!'), backgroundColor: Colors.orange),
                                     );
                                   }
                                 },
                                 icon: const Icon(Icons.notifications_active, size: 16),
                                 label: Text('Enable Notifications', style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w600)),
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: AppColors.primary,
                                   foregroundColor: AppColors.surface,
                                   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                   shape: StadiumBorder(),
                                 ),
                               ),
                            ],
                          ),
                        ),

                        // Table Header
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: AppColors.border),
                              bottom: BorderSide(color: AppColors.border),
                            ),
                            color: AppColors.background,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              _headerCell('ORDER ID', flex: 3),
                              _headerCell('CUSTOMER', flex: 2),
                              _headerCell('PRODUCTS', flex: 2),
                              _headerCell('AMOUNT', flex: 2),
                              _headerCell('STATUS', flex: 3),
                              _headerCell('AWB', flex: 2),
                              _headerCell('DATE', flex: 2),
                              _headerCell('ACTIONS', flex: 3),
                            ],
                          ),
                        ),

                        if (orders.isEmpty)
                          // Empty State
                          SizedBox(
                            height: 280,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: AppColors.muted,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.receipt_long_outlined,
                                      size: 40,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No orders found',
                                    style: GoogleFonts.instrumentSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'No orders match the selected filter criteria.',
                                    style: GoogleFonts.instrumentSans(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              debugPrint('--- Vendor Order [${order['orderId']}] Tracking URL: ${order['trackingUrl']} ---');
                              final String orderId = order['orderId'] ?? 'ID';
                              final String customer = order['user'] != null ? order['user']['name'] : 'Guest';
                              final List items = order['items'] ?? [];
                              final String products = items.isNotEmpty ? items[0]['name'] : 'Item';
                              final double amount = (order['totalAmount'] ?? 0).toDouble();
                              final String effectiveStatus = _getEffectiveStatus(order);
                              final String date = order['createdAt'] != null ? DateTime.parse(order['createdAt']).toString().split(' ')[0] : '-';

                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: AppColors.muted)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 16,
                                      child: InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => OrderDetailsDialog(order: order, controller: _controller),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Expanded(flex: 3, child: Text(orderId, style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w500))),
                                            Expanded(flex: 2, child: Text(customer, style: GoogleFonts.instrumentSans(fontSize: 13))),
                                            Expanded(flex: 2, child: Text(products + (items.length > 1 ? ' +${items.length - 1}' : ''), style: GoogleFonts.instrumentSans(fontSize: 13), overflow: TextOverflow.ellipsis)),
                                            Expanded(flex: 2, child: Text('₹$amount', style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w600))),
                                            Expanded(flex: 3, child: _buildStatusBadge(effectiveStatus)),
                                            Expanded(
                                              flex: 2, 
                                              child: Text(
                                                order['awb'] ?? '-', 
                                                style: GoogleFonts.instrumentSans(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Expanded(flex: 2, child: Text(date, style: GoogleFonts.instrumentSans(fontSize: 13))),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          /*
                                          IconButton(
                                            onPressed: (order['status'].toString().toLowerCase() != 'cancelled' &&
                                                    order['status'].toString().toLowerCase() != 'pending')
                                                ? () async {
                                                    final challanUrl = order['delhiveryChallanUrl'];
                                                    if (challanUrl != null && challanUrl.toString().trim().isNotEmpty) {
                                                      final urls = challanUrl.toString().split(',');
                                                      for (int i = 0; i < urls.length; i++) {
                                                        final trimmedUrl = urls[i].trim();
                                                        if (trimmedUrl.isNotEmpty) {
                                                          final fileName = urls.length == 1
                                                              ? 'challan_${order['orderId']}.pdf'
                                                              : 'challan_${order['orderId']}_${i + 1}.pdf';
                                                          await _downloadFile(trimmedUrl, fileName);
                                                        }
                                                      }
                                                    } else {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => ShippingLabelDialog(order: order),
                                                      );
                                                    }
                                                  }
                                                : null,
                                            icon: Icon(
                                              Icons.local_shipping_outlined,
                                              size: 20,
                                              color: (order['status'].toString().toLowerCase() != 'cancelled' &&
                                                      order['status'].toString().toLowerCase() != 'pending')
                                                  ? Colors.orange.shade700
                                                  : AppColors.textLight.withOpacity(0.3),
                                            ),
                                            tooltip: (order['delhiveryChallanUrl'] != null && order['delhiveryChallanUrl'].toString().trim().isNotEmpty)
                                                ? 'Download Delhivery Challan'
                                                : 'Download Shipping Label',
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          */
                                          /*
                                          if (order['delhiveryChallanUrl'] != null && order['delhiveryChallanUrl'].toString().trim().isNotEmpty) ...[
                                            InkWell(
                                              onTap: () async {
                                                final challanUrl = order['delhiveryChallanUrl'];
                                                final urls = challanUrl.toString().split(',');
                                                for (int i = 0; i < urls.length; i++) {
                                                  final trimmedUrl = urls[i].trim();
                                                  if (trimmedUrl.isNotEmpty) {
                                                    final fileName = urls.length == 1
                                                        ? 'challan_${order['orderId']}.pdf'
                                                        : 'challan_${order['orderId']}_${i + 1}.pdf';
                                                    await _downloadFile(trimmedUrl, fileName);
                                                  }
                                                }
                                              },
                                              borderRadius: BorderRadius.circular(20),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF3E8FF),
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(color: const Color(0xFFD8B4FE)),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.file_download_outlined, size: 14, color: Colors.purple.shade700),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Challan',
                                                      style: GoogleFonts.instrumentSans(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.purple.shade700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          */
                                          if (order['trackingUrl'] != null && order['trackingUrl'].toString().isNotEmpty) ...[
                                            InkWell(
                                              onTap: () async {
                                                final url = Uri.parse(order['trackingUrl']);
                                                try {
                                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                                } catch (e) {
                                                  debugPrint('Error launching URL: $e');
                                                }
                                              },
                                              borderRadius: BorderRadius.circular(20),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: AppColors.muted,
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(color: AppColors.border),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.explore_outlined, size: 14, color: AppColors.textPrimary),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Track',
                                                      style: GoogleFonts.instrumentSans(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppColors.textPrimary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                          const SizedBox(width: 8),
                                          /*
                                          PopupMenuButton<String>(
                                            tooltip: 'Update Status',
                                            enabled: order['status'].toString().toLowerCase() != 'delivered',
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: AppColors.muted,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Icon(Icons.more_horiz, size: 18, color: AppColors.textPrimary),
                                            ),
                                            onSelected: (val) => _controller.updateOrderStatus(order['_id'], val),
                                            itemBuilder: (context) {
                                              final s = order['status'].toString().toUpperCase();
                                              final isPendingAcceptance = s == 'CREATED' || s == 'PAID';
                                              final list = isPendingAcceptance
                                                  ? ['Accept Order', 'Cancelled']
                                                  : ['Shipped', 'Delivered', 'Cancelled'];
                                              return list.map((e) {
                                                final val = e == 'Accept Order' ? 'Processing' : e;
                                                return PopupMenuItem(value: val, child: Text(e));
                                              }).toList();
                                            },
                                          ),
                                          */
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.amber;
    final s = status.toUpperCase();
    if (s == 'SHIPPED' || s == 'OUT_FOR_DELIVERY') {
      color = Colors.blue;
    } else if (s == 'DELIVERED') color = Colors.green;
    else if (s == 'CANCELLED') color = Colors.red;
    else if (s == 'PROCESSING') color = Colors.indigo;
    else if (s == 'ESCALATED') color = Colors.deepOrange;
    else if (s == 'SHIPMENT REQUESTED' || s == 'PICKUP REQUESTED') color = Colors.purple;
    else if (s == 'SHIPMENT SCHEDULED' || s == 'PICKUP SCHEDULED') color = Colors.teal;
    else if (s == 'PICKED UP') color = Colors.indigo;
    else if (s == 'READY TO DISPATCH' || s == 'READY_TO_DISPATCH') color = Colors.orange;

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
                  fontWeight: FontWeight.w600,
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

  Widget _headerCell(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: GoogleFonts.instrumentSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color dotColor;
  final VoidCallback onTap;
  final bool isSelected;

  const _StatCard({
    required this.label,
    required this.value,
    required this.dotColor,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.instrumentSans(
                fontSize: 13,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: GoogleFonts.instrumentSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w400, letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
