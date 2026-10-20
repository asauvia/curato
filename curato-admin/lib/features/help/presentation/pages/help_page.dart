import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curato_admin/features/layout/presentation/widgets/admin_layout.dart';
import 'package:curato_admin/core/services/service_locator.dart';
import 'package:curato_admin/features/help/data/services/admin_support_service.dart';
import 'package:curato_admin/features/help/domain/models/support_ticket_model.dart';
import 'package:intl/intl.dart';

import '../../data/services/faq_admin_service.dart';
import '../../data/services/resource_admin_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';


import 'package:curato_admin/core/constants/app_colors.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final List<String> _tabs = ['Support Tickets', 'Vendor FAQs', 'Vendor Resources'];
  String _selectedTab = 'Support Tickets';
  
  String _ticketType = 'Vendor'; // 'Vendor' or 'User'
  final FaqAdminService _faqService = FaqAdminService();
  final ResourceAdminService _resourceService = ResourceAdminService();
  String _faqSearch = '';
  Key _resourceKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/help',
      child: Column(
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
                Text('Help Management', style: GoogleFonts.instrumentSans(color: AppColors.mutedForeground, fontSize: 13)),
                if (_selectedTab != 'Support Tickets') ...[
                  const Icon(Icons.chevron_right, size: 18, color: AppColors.mutedForeground),
                  Text(_selectedTab, style: GoogleFonts.instrumentSans(color: AppColors.foreground, fontWeight: FontWeight.bold, fontSize: 13)),
                ]
              ],
            ),
          ),

          // Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: _tabs.map<Widget>((tab) {
                final isSelected = _selectedTab == tab;
                return InkWell(
                  onTap: () => setState(() => _selectedTab = tab),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? AppColors.foreground : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      tab,
                      style: GoogleFonts.instrumentSans(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? AppColors.foreground : AppColors.mutedForeground,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: _selectedTab == 'Vendor FAQs'
                  ? _buildFaqManagement()
                  : _selectedTab == 'Vendor Resources'
                      ? _buildResourceManagement()
                      : _buildSupportTickets(),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSupportTickets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_ticketType Support Tickets',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.5,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Review and respond to help requests from ${_ticketType.toLowerCase()}s',
                  style: GoogleFonts.instrumentSans(color: AppColors.mutedForeground, fontSize: 14),
                ),
              ],
            ),
            Row(
              children: [
                _buildTicketTypeToggle(),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh Tickets',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 28),
        FutureBuilder<List<SupportTicketModel>>(
          future: _ticketType == 'Vendor' 
            ? sl<AdminSupportService>().getAllTickets()
            : sl<AdminSupportService>().getAllUserTickets(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(100), child: CircularProgressIndicator()));
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyTickets();
            }

            final tickets = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return _buildTicketCard(ticket);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildTicketTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: ['Vendor', 'User'].map((type) {
          final isSelected = _ticketType == type;
          return GestureDetector(
            onTap: () => setState(() => _ticketType = type),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.background : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: isSelected ? Border.all(color: AppColors.border) : null,
              ),
              child: Text(
                '$type Tickets',
                style: GoogleFonts.instrumentSans(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.foreground : AppColors.mutedForeground,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTicketCard(SupportTicketModel ticket) {
    Color statusColor;
    switch (ticket.status) {
      case 'Open': statusColor = AppColors.foreground; break;
      case 'In Progress': statusColor = AppColors.mutedForeground; break;
      case 'Resolved': statusColor = AppColors.signal; break;
      default: statusColor = AppColors.mutedForeground;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ticket.status.toUpperCase(),
                      style: GoogleFonts.instrumentSans(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Ticket ID: ${ticket.ticketId}',
                    style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.mutedForeground),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.muted,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ticket.category,
                      style: GoogleFonts.instrumentSans(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.foreground),
                    ),
                  ),
                ],
              ),
              Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(ticket.createdAt),
                style: GoogleFonts.instrumentSans(fontSize: 12, color: AppColors.mutedForeground),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ticket.subject,
            style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.foreground),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(_ticketType == 'Vendor' ? Icons.business : Icons.person_outline, size: 14, color: AppColors.mutedForeground),
              const SizedBox(width: 6),
              Text(
                '${_ticketType == 'Vendor' ? 'Vendor' : 'User'}: ${ticket.vendorName}',
                style: GoogleFonts.instrumentSans(fontSize: 13, color: AppColors.mutedForeground),
              ),
              const SizedBox(width: 20),
              Icon(Icons.phone, size: 14, color: AppColors.mutedForeground),
              const SizedBox(width: 6),
              Text(
                ticket.phone,
                style: GoogleFonts.instrumentSans(fontSize: 13, color: AppColors.mutedForeground),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _showTicketDetails(ticket),
                child: Text('View Details & Respond', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w600, color: AppColors.foreground)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTickets() {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.confirmation_number_outlined, color: AppColors.border, size: 48),
            const SizedBox(height: 16),
            Text(
              'No support tickets raised yet',
              style: GoogleFonts.instrumentSans(color: AppColors.mutedForeground, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _showTicketDetails(SupportTicketModel ticket) {
    final replyController = TextEditingController();
    String selectedStatus = ticket.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Ticket: ${ticket.ticketId}', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w400, letterSpacing: -0.5)),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status', style: GoogleFonts.instrumentSans(fontSize: 12, color: AppColors.mutedForeground)),
                          const SizedBox(height: 4),
                          DropdownButton<String>(
                            value: selectedStatus,
                            items: ['Open', 'In Progress', 'Resolved', 'Closed']
                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (v) async {
                              bool success = false;
                              if (_ticketType == 'Vendor') {
                                success = await sl<AdminSupportService>().updateStatus(ticket.id, v!);
                              } else {
                                success = await sl<AdminSupportService>().updateUserTicketStatus(ticket.id, v!);
                              }
                              if (success) setState(() => selectedStatus = v);
                            },
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Priority', style: GoogleFonts.instrumentSans(fontSize: 12, color: AppColors.mutedForeground)),
                          const SizedBox(height: 4),
                          Text(ticket.priority, style: GoogleFonts.instrumentSans(fontWeight: FontWeight.bold, color: Colors.red)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Text('Issue Description', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.muted,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(ticket.message, style: GoogleFonts.instrumentSans(fontSize: 14)),
                  ),
                  const SizedBox(height: 24),
                  Text('Responses', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (ticket.responses != null && ticket.responses!.isNotEmpty)
                    ...ticket.responses!.map((r) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: r.sender == 'Admin' ? AppColors.muted : AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: r.sender == 'Admin' ? AppColors.border : AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(r.sender, style: GoogleFonts.instrumentSans(fontSize: 11, fontWeight: FontWeight.bold, color: r.sender == 'Admin' ? AppColors.foreground : AppColors.mutedForeground)),
                                  Text(DateFormat('dd MMM, hh:mm a').format(r.createdAt), style: GoogleFonts.instrumentSans(fontSize: 10, color: AppColors.mutedForeground)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(r.message, style: GoogleFonts.instrumentSans(fontSize: 13)),
                            ],
                          ),
                        )),
                  const SizedBox(height: 16),
                  TextField(
                    controller: replyController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Type your response here...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ElevatedButton(
              onPressed: () async {
                if (replyController.text.isNotEmpty) {
                  bool success = false;
                  if (_ticketType == 'Vendor') {
                    success = await sl<AdminSupportService>().addResponse(ticket.id, replyController.text);
                  } else {
                    success = await sl<AdminSupportService>().addUserTicketResponse(ticket.id, replyController.text);
                  }

                  if (success && context.mounted) {
                    Navigator.pop(context);
                    this.setState(() {}); // Refresh main list
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.foreground, foregroundColor: AppColors.background),
              child: const Text('Send Response'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vendor FAQ Management',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.5,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage questions and answers displayed on Vendor Help section',
                  style: GoogleFonts.instrumentSans(color: AppColors.mutedForeground, fontSize: 14),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showFaqDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: Text('Add New FAQ', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.foreground,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: StadiumBorder(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        FutureBuilder<List<dynamic>>(
          future: _faqService.getAllFaqs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(80), child: CircularProgressIndicator()));
            }

            final faqs = snapshot.data ?? [];
            final filteredFaqs = faqs.where((f) {
              final q = (f['question'] ?? '').toString().toLowerCase();
              final a = (f['answer'] ?? '').toString().toLowerCase();
              return q.contains(_faqSearch.toLowerCase()) || a.contains(_faqSearch.toLowerCase());
            }).toList();

            return Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    width: 400,
                    height: 42,
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
                            onChanged: (v) => setState(() => _faqSearch = v),
                            decoration: InputDecoration(
                              hintText: 'Search FAQ questions or answers...',
                              hintStyle: GoogleFonts.instrumentSans(color: AppColors.mutedForeground, fontSize: 13),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (filteredFaqs.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(60),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.quiz_outlined, size: 48, color: AppColors.border),
                          const SizedBox(height: 12),
                          Text('No Vendor FAQs created yet', style: GoogleFonts.instrumentSans(fontSize: 14, color: AppColors.mutedForeground)),
                          const SizedBox(height: 8),
                          Text('Click "Add New FAQ" button above to publish your first Vendor Q&A.', style: GoogleFonts.instrumentSans(fontSize: 12, color: AppColors.mutedForeground)),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredFaqs.length,
                      separatorBuilder: (_, __) => const Divider(height: 24),
                      itemBuilder: (context, index) {
                        final faq = filteredFaqs[index];
                        final String id = faq['_id'] ?? '';
                        final bool isActive = faq['isActive'] ?? true;
                        final String category = faq['category'] ?? 'General';

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
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.muted,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Text(
                                      category.toUpperCase(),
                                      style: GoogleFonts.instrumentSans(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.foreground),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isActive ? AppColors.signalTint : AppColors.muted,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isActive ? 'ACTIVE' : 'INACTIVE',
                                      style: GoogleFonts.instrumentSans(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? AppColors.signal : AppColors.mutedForeground),
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.foreground),
                                    tooltip: 'Edit FAQ',
                                    onPressed: () => _showFaqDialog(faq: faq),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                    tooltip: 'Delete FAQ',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete FAQ?'),
                                          content: const Text('Are you sure you want to delete this FAQ?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                              child: const Text('Delete', style: TextStyle(color: AppColors.background)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await _faqService.deleteFaq(id);
                                        setState(() {});
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Q: ${faq['question'] ?? ''}',
                                style: GoogleFonts.instrumentSans(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.foreground),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'A: ${faq['answer'] ?? ''}',
                                style: GoogleFonts.instrumentSans(fontSize: 13, color: AppColors.foreground),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showFaqDialog({Map<String, dynamic>? faq}) {
    final isEditing = faq != null;
    final qController = TextEditingController(text: faq?['question'] ?? '');
    final aController = TextEditingController(text: faq?['answer'] ?? '');
    String category = faq?['category'] ?? 'General';
    bool isActive = faq?['isActive'] ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: Text(isEditing ? 'Edit Vendor FAQ' : 'Add New Vendor FAQ', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w400, letterSpacing: -0.5)),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Category *', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: category,
                    items: ['General', 'Orders & Shipping', 'Payments & Payouts', 'Products & Inventory', 'Account']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setDlgState(() => category = v!),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Question *', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: qController,
                    decoration: InputDecoration(
                      hintText: 'e.g. How do I request order pickup from admin?',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Answer *', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: aController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Provide detailed clear answer for vendors...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: isActive,
                        onChanged: (v) => setDlgState(() => isActive = v!),
                      ),
                      Text('Active (Visible to Vendors)', style: GoogleFonts.instrumentSans(fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (qController.text.trim().isEmpty || aController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill both Question and Answer fields'), backgroundColor: Colors.red),
                  );
                  return;
                }

                final data = {
                  'question': qController.text.trim(),
                  'answer': aController.text.trim(),
                  'category': category,
                  'targetAudience': 'VENDOR',
                  'isActive': isActive,
                };

                bool success;
                if (isEditing) {
                  success = await _faqService.updateFaq(faq['_id'], data);
                } else {
                  success = await _faqService.createFaq(data);
                }

                if (success && context.mounted) {
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.foreground, foregroundColor: AppColors.background),
              child: Text(isEditing ? 'Save Changes' : 'Create FAQ'),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────── RESOURCES MANAGEMENT ───────────────────────

  Widget _buildResourceManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vendor Resource Library',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.5,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload video tutorials, PDF guides, and blog links for vendors',
                  style: GoogleFonts.instrumentSans(color: AppColors.mutedForeground, fontSize: 14),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showResourceDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: Text('Add Resource', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.foreground,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: StadiumBorder(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        FutureBuilder<List<dynamic>>(
          key: _resourceKey,
          future: _resourceService.getAllResources(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(80), child: CircularProgressIndicator()));
            }

            final resources = snapshot.data ?? [];

            if (resources.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(80),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.video_library_outlined, size: 56, color: AppColors.border),
                    const SizedBox(height: 16),
                    Text('No resources added yet', style: GoogleFonts.instrumentSans(fontSize: 14, color: AppColors.mutedForeground)),
                    const SizedBox(height: 8),
                    Text('Click "Add Resource" to upload a video, PDF, or blog link for vendors.', style: GoogleFonts.instrumentSans(fontSize: 12, color: AppColors.mutedForeground)),
                  ],
                ),
              );
            }

            // Group by type
            final videos = resources.where((r) => r['type'] == 'VIDEO').toList();
            final pdfs = resources.where((r) => r['type'] == 'PDF').toList();
            final blogs = resources.where((r) => r['type'] == 'BLOG').toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (videos.isNotEmpty) _buildResourceSection('📹 Video Tutorials', videos, AppColors.muted, AppColors.foreground),
                if (pdfs.isNotEmpty) ...[const SizedBox(height: 24), _buildResourceSection('📄 PDF Guides', pdfs, AppColors.muted, AppColors.foreground)],
                if (blogs.isNotEmpty) ...[const SizedBox(height: 24), _buildResourceSection('📝 Blog Articles', blogs, AppColors.signalTint, AppColors.signal)],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildResourceSection(String title, List<dynamic> items, Color bgColor, Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Text(title, style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.bold, color: accentColor.withOpacity(0.85))),
                const Spacer(),
                Text('${items.length} item(s)', style: GoogleFonts.instrumentSans(fontSize: 12, color: accentColor.withOpacity(0.7))),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final r = items[index];
              final bool isActive = r['isActive'] ?? true;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: bgColor,
                  child: Icon(
                    r['type'] == 'VIDEO' ? Icons.play_circle_outline
                        : r['type'] == 'PDF' ? Icons.picture_as_pdf_outlined
                        : Icons.article_outlined,
                    color: accentColor,
                    size: 20,
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(r['title'] ?? '', style: GoogleFonts.instrumentSans(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.signalTint : AppColors.muted,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isActive ? 'ACTIVE' : 'INACTIVE',
                        style: GoogleFonts.instrumentSans(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? AppColors.signal : AppColors.mutedForeground),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((r['description'] ?? '').toString().isNotEmpty) ...
                      [const SizedBox(height: 2), Text(r['description'], style: GoogleFonts.instrumentSans(fontSize: 12, color: AppColors.mutedForeground))],
                    const SizedBox(height: 4),
                    Text(r['url'] ?? '', style: GoogleFonts.instrumentSans(fontSize: 11, color: AppColors.foreground), overflow: TextOverflow.ellipsis),
                    if ((r['category'] ?? '').toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('Category: ${r['category']}', style: GoogleFonts.instrumentSans(fontSize: 11, color: AppColors.mutedForeground)),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.foreground),
                      tooltip: 'Edit Resource',
                      onPressed: () => _showResourceDialog(resource: r),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      tooltip: 'Delete Resource',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Resource?'),
                            content: Text('Delete "${r['title']}"?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('Delete', style: TextStyle(color: AppColors.background)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await _resourceService.deleteResource(r['_id']);
                          setState(() => _resourceKey = UniqueKey());
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showResourceDialog({Map<String, dynamic>? resource}) {
    final isEditing = resource != null;
    final titleCtrl = TextEditingController(text: resource?['title'] ?? '');
    final descCtrl = TextEditingController(text: resource?['description'] ?? '');
    final urlCtrl = TextEditingController(text: resource?['url'] ?? '');
    final contentCtrl = TextEditingController(text: resource?['content'] ?? '');
    String type = resource?['type'] ?? 'VIDEO';
    String category = resource?['category'] ?? 'General';
    bool isActive = resource?['isActive'] ?? true;

    Uint8List? selectedPdfBytes;
    String? selectedPdfName;
    bool isUploadingPdf = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: Text(
            isEditing ? 'Edit Resource' : 'Add Vendor Resource',
            style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w400, letterSpacing: -0.5),
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Type selector
                  Text('Resource Type *', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final t in [('VIDEO', Icons.videocam_outlined, AppColors.foreground), ('PDF', Icons.picture_as_pdf_outlined, AppColors.foreground), ('BLOG', Icons.article_outlined, AppColors.signal)])
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDlgState(() => type = t.$1),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: type == t.$1 ? t.$3.withOpacity(0.1) : AppColors.muted,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: type == t.$1 ? t.$3 : AppColors.border,
                                  width: type == t.$1 ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(t.$2, color: type == t.$1 ? t.$3 : AppColors.mutedForeground, size: 22),
                                  const SizedBox(height: 4),
                                  Text(t.$1, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w600, color: type == t.$1 ? t.$3 : AppColors.mutedForeground)),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text('Title *', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      hintText: type == 'VIDEO' ? 'e.g. How to Add Your First Product' : type == 'PDF' ? 'e.g. Vendor Onboarding Guide' : 'e.g. Top 5 Selling Tips',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text('Description (optional)', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Brief summary of this resource...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (type == 'BLOG') ...[
                    Text('Blog Article Content *', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: contentCtrl,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: 'Write the blog article content here...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else if (type == 'PDF') ...[
                    Text('PDF / Word Document (.pdf, .doc, .docx) *', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.muted,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              selectedPdfName ?? (urlCtrl.text.isNotEmpty ? 'Currently: ${urlCtrl.text.split('/').last}' : 'No document selected'),
                              style: GoogleFonts.instrumentSans(fontSize: 12, color: AppColors.foreground),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              FilePickerResult? result = await FilePicker.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['pdf', 'doc', 'docx'],
                              );
                              if (result != null && result.files.single.bytes != null) {
                                setDlgState(() {
                                  selectedPdfBytes = result.files.single.bytes;
                                  selectedPdfName = result.files.single.name;
                                });
                              }
                            } catch (e) {
                              debugPrint('Error picking file: $e');
                            }
                          },
                          icon: const Icon(Icons.file_upload, size: 16),
                          label: const Text('Browse'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.foreground,
                            foregroundColor: AppColors.background,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('OR enter Document URL manually:', style: GoogleFonts.instrumentSans(fontSize: 11, color: AppColors.mutedForeground)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: urlCtrl,
                      decoration: InputDecoration(
                        hintText: 'https://example.com/document.pdf or .docx',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    Text(
                      'YouTube Video URL *',
                      style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: urlCtrl,
                      decoration: InputDecoration(
                        hintText: 'https://www.youtube.com/watch?v=...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.link, size: 18, color: AppColors.mutedForeground),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Text('Category', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: category,
                    items: ['General', 'Getting Started', 'Products & Inventory', 'Orders & Shipping', 'Payments & Payouts', 'Marketing']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setDlgState(() => category = v!),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Checkbox(value: isActive, onChanged: (v) => setDlgState(() => isActive = v!)),
                      Text('Active (Visible to Vendors)', style: GoogleFonts.instrumentSans(fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isUploadingPdf ? null : () async {
                if (titleCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title is required'), backgroundColor: Colors.red),
                  );
                  return;
                }
                if (type == 'BLOG' && contentCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Blog content is required'), backgroundColor: Colors.red),
                  );
                  return;
                }
                if (type != 'BLOG' && urlCtrl.text.trim().isEmpty && selectedPdfBytes == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('URL or PDF File is required'), backgroundColor: Colors.red),
                  );
                  return;
                }

                setDlgState(() => isUploadingPdf = true);
                String finalUrl = urlCtrl.text.trim();

                if (type == 'PDF' && selectedPdfBytes != null) {
                  final uploadedUrl = await _resourceService.uploadPdf(selectedPdfBytes!, selectedPdfName ?? 'guide.pdf');
                  if (uploadedUrl != null) {
                    finalUrl = uploadedUrl;
                  } else {
                    setDlgState(() => isUploadingPdf = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to upload PDF file'), backgroundColor: Colors.red),
                      );
                    }
                    return;
                  }
                }

                final data = {
                  'title': titleCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'type': type,
                  'url': finalUrl,
                  'content': contentCtrl.text.trim(),
                  'category': category,
                  'targetAudience': 'VENDOR',
                  'isActive': isActive,
                };
                bool success;
                if (isEditing) {
                  success = await _resourceService.updateResource(resource['_id'], data);
                } else {
                  success = await _resourceService.createResource(data);
                }
                setDlgState(() => isUploadingPdf = false);
                if (success && context.mounted) {
                  Navigator.pop(context);
                  setState(() => _resourceKey = UniqueKey());
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.foreground, foregroundColor: AppColors.background),
              child: isUploadingPdf
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: AppColors.background, strokeWidth: 2))
                  : Text(isEditing ? 'Save Changes' : 'Add Resource'),
            ),
          ],
        ),
      ),
    );
  }
}
