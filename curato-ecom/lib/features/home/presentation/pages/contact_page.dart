import 'package:curato_user/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curato_user/core/widgets/curato_layout.dart';
import 'package:curato_user/core/widgets/centered_content.dart';
import 'package:curato_user/core/utils/responsive.dart';
import 'package:curato_user/core/controllers/settings_controller.dart';
import 'package:curato_user/core/services/support_service.dart';
import 'package:curato_user/core/services/session_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _selectedCategory = 'General';
  String _selectedPriority = 'Medium';
  bool _isLoading = false;
  int _activeOption = 0; // 0: Direct Email, 1: Raise Ticket, 2: Track Tickets
  List<dynamic> _myTickets = [];
  bool _fetchingTickets = false;

  final List<String> _categories = [
    'General',
    'Order Support',
    'Payment Issue',
    'Product Quality',
    'Technical Help',
    'Other'
  ];

  final List<String> _priorities = ['Low', 'Medium', 'High', 'Urgent'];

  @override
  void initState() {
    super.initState();
    final user = SessionService.instance.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.mobile ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    if (SessionService.instance.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to raise a ticket')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await SupportService.createTicket(
      category: _selectedCategory,
      subject: _subjectController.text,
      message: _messageController.text,
      phone: _phoneController.text,
      priority: _selectedPriority,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      _subjectController.clear();
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ticket #${result['data']['ticketId']} raised successfully!'),
          backgroundColor: AppColors.signal,
        ),
      );
      // Automatically switch to track tickets
      setState(() => _activeOption = 2);
      _fetchMyTickets();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to raise ticket'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  Future<void> _fetchMyTickets() async {
    setState(() => _fetchingTickets = true);
    final result = await SupportService.getMyTickets();
    if (result['success']) {
      setState(() {
        _myTickets = result['data'];
      });
    }
    setState(() => _fetchingTickets = false);
  }

  Future<void> _launchEmail() async {
    final settings = SettingsController.instance.settings;
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: settings.contactEmail,
      query: 'subject=Support Request - ${settings.marketplaceName}',
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch email app')),
        );
      }
    }
  }

  Future<void> _launchPhone(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri uri = Uri(scheme: 'tel', path: cleanPhone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchMaps() async {
    final Uri uri = Uri.parse('https://maps.app.goo.gl/o5DBPxAU2hb2sVqs7');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);
    final settings = SettingsController.instance.settings;

    return CuratoLayout(
      activeTitle: 'CONTACT US',
      child: Container(
        color: AppColors.background,
        padding: EdgeInsets.symmetric(vertical: isMobile ? 32 : 60),
        child: CenteredContent(
          horizontalPadding: isMobile ? 16 : 40,
          child: Column(
            children: [
              // 1. Header
              _buildHeader(isMobile),
              SizedBox(height: isMobile ? 32 : 48),

              // 2. Option Selector
              _buildOptionSelector(isMobile),
              SizedBox(height: isMobile ? 32 : 48),

              // 3. Main Content
              _activeOption == 0 
                ? _buildEmailSection(isMobile, settings) 
                : _activeOption == 1 
                  ? _buildTicketSection(isMobile)
                  : _buildTrackTicketsSection(isMobile),
              
              SizedBox(height: isMobile ? 48 : 80),

              // 4. Info Cards (Moved down to focus on contact options)
              _buildInfoCards(isMobile, isTablet, settings),
              SizedBox(height: isMobile ? 32 : 64),

              // 5. FAQ Section
              _buildFAQSection(isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Column(
      children: [
        Text(
          'Get In Touch',
          style: GoogleFonts.instrumentSans(
            fontSize: isMobile ? 32 : 48,
            fontWeight: FontWeight.w400,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 700,
          child: Text(
            "Have a question or need assistance? Choose the best way to reach us. Our team is ready to help you.",
            textAlign: TextAlign.center,
            style: GoogleFonts.instrumentSans(
              fontSize: isMobile ? 14 : 16,
              color: AppColors.mutedForeground,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionSelector(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _optionButton(0, Icons.email_outlined, 'Direct Email'),
          _optionButton(1, Icons.confirmation_number_outlined, 'Raise a Ticket'),
          _optionButton(2, Icons.history_rounded, 'Track Tickets'),
        ],
      ),
    );
  }

  Widget _optionButton(int index, IconData icon, String label) {
    final bool isActive = _activeOption == index;
    return GestureDetector(
      onTap: () {
        setState(() => _activeOption = index);
        if (index == 2) _fetchMyTickets();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.white : AppColors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? AppColors.primaryPink : AppColors.mutedForeground, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.instrumentSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.foreground : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailSection(bool isMobile, settings) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 800),
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      decoration: BoxDecoration(border: Border.all(color: AppColors.border),
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: AppColors.muted, shape: BoxShape.circle),
            child: const Icon(Icons.email_outlined, color: AppColors.primaryPink, size: 40),
          ),
          const SizedBox(height: 32),
          Text(
            'Email Our Support Team',
            style: GoogleFonts.instrumentSans(fontSize: 24, fontWeight: FontWeight.w400, color: AppColors.foreground),
          ),
          const SizedBox(height: 16),
          Text(
            'Prefer to send a traditional email? Our support agents typically respond within 24 business hours.',
            textAlign: TextAlign.center,
            style: GoogleFonts.instrumentSans(color: AppColors.mutedForeground, height: 1.6),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: SelectableText(
              settings.contactEmail,
              style: GoogleFonts.instrumentSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryPink),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 250,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _launchEmail,
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text('Open Email App', style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
                foregroundColor: AppColors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackTicketsSection(bool isMobile) {
    if (SessionService.instance.token == null) {
      return _buildLoginRequired(isMobile);
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 1000),
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      decoration: BoxDecoration(border: Border.all(color: AppColors.border),
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Support Tickets', style: GoogleFonts.instrumentSans(fontSize: 24, fontWeight: FontWeight.w400, color: AppColors.foreground)),
                  const SizedBox(height: 8),
                  Text('Track the status of your requests and see admin responses.', style: GoogleFonts.instrumentSans(color: AppColors.mutedForeground)),
                ],
              ),
              IconButton(
                onPressed: _fetchMyTickets,
                icon: Icon(_fetchingTickets ? Icons.sync : Icons.refresh, color: AppColors.primaryPink),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 40),
          
          if (_fetchingTickets && _myTickets.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else if (_myTickets.isEmpty)
            _buildEmptyTickets()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _myTickets.length,
              itemBuilder: (context, index) {
                final ticket = _myTickets[index];
                return _buildTicketListItem(ticket, isMobile);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLoginRequired(bool isMobile) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 800),
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      decoration: BoxDecoration(border: Border.all(color: AppColors.border),
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock_outline, size: 64, color: AppColors.mutedForeground),
          const SizedBox(height: 24),
          Text(
            'Login Required',
            style: GoogleFonts.instrumentSans(fontSize: 24, fontWeight: FontWeight.w400, color: AppColors.foreground),
          ),
          const SizedBox(height: 16),
          Text(
            'You need to be logged in to track your support tickets.',
            textAlign: TextAlign.center,
            style: GoogleFonts.instrumentSans(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.foreground,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: const StadiumBorder(),
            ),
            child: const Text('Login to Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTickets() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.confirmation_number_outlined, size: 48, color: AppColors.grey300),
            const SizedBox(height: 16),
            Text('No tickets found', style: GoogleFonts.instrumentSans(color: AppColors.grey500, fontWeight: FontWeight.w500)),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => setState(() => _activeOption = 1),
              child: Text('Raise a New Ticket', style: GoogleFonts.instrumentSans(color: AppColors.primaryPink, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketListItem(dynamic ticket, bool isMobile) {
    final status = ticket['status'] ?? 'Open';
    Color statusColor;
    switch (status) {
      case 'Open': statusColor = AppColors.blue500; break;
      case 'In Progress': statusColor = AppColors.foreground; break;
      case 'Resolved': statusColor = AppColors.signal; break;
      case 'Closed': statusColor = AppColors.grey; break;
      default: statusColor = AppColors.blue500;
    }

    final responses = (ticket['responses'] as List?) ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                status.toUpperCase(),
                style: GoogleFonts.instrumentSans(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ticket['subject'] ?? 'No Subject',
                style: GoogleFonts.instrumentSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.foreground),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Text(
                'ID: ${ticket['ticketId']}',
                style: GoogleFonts.instrumentSans(fontSize: 12, color: AppColors.mutedForeground),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.circle, size: 4, color: AppColors.border),
              const SizedBox(width: 12),
              Text(
                ticket['category'] ?? 'General',
                style: GoogleFonts.instrumentSans(fontSize: 12, color: AppColors.mutedForeground),
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 32),
                Text('Description:', style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
                const SizedBox(height: 8),
                Text(
                  ticket['message'] ?? '',
                  style: GoogleFonts.instrumentSans(fontSize: 14, color: AppColors.foreground, height: 1.5),
                ),
                
                if (responses.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Admin Response:', style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryPink)),
                  const SizedBox(height: 12),
                  ...responses.where((r) => r['sender'] == 'Admin').map((r) => Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r['message'] ?? '',
                          style: GoogleFonts.instrumentSans(fontSize: 14, color: AppColors.foreground, height: 1.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Replied by Admin',
                          style: GoogleFonts.instrumentSans(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.mutedForeground),
                        ),
                      ],
                    ),
                  )),
                ],
                
                if (status == 'Resolved') ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(border: Border.all(color: AppColors.border), color: AppColors.muted, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.signal, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This issue has been marked as resolved.',
                            style: GoogleFonts.instrumentSans(fontSize: 13, color: AppColors.signal, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketSection(bool isMobile) {
    if (SessionService.instance.token == null) {
      return _buildLoginRequired(isMobile);
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 1000),
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      decoration: BoxDecoration(border: Border.all(color: AppColors.border),
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Raise a Support Ticket', style: GoogleFonts.instrumentSans(fontSize: 24, fontWeight: FontWeight.w400, color: AppColors.foreground)),
            const SizedBox(height: 8),
            Text('Track your requests and get notified when our team responds.', style: GoogleFonts.instrumentSans(color: AppColors.mutedForeground)),
            const SizedBox(height: 40),
            
            if (isMobile) ...[
              _buildField('Full Name *', _nameController, hint: 'Your full name', readOnly: true),
              const SizedBox(height: 24),
              _buildField('Email Address *', _emailController, hint: 'your@email.com', readOnly: true),
            ] else
              Row(
                children: [
                  Expanded(child: _buildField('Full Name *', _nameController, hint: 'Your full name', readOnly: true)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildField('Email Address *', _emailController, hint: 'your@email.com', readOnly: true)),
                ],
              ),
            
            const SizedBox(height: 24),
            
            if (isMobile) ...[
              _buildDropdown('Category *', _selectedCategory, _categories, (v) => setState(() => _selectedCategory = v!)),
              const SizedBox(height: 24),
              _buildDropdown('Priority *', _selectedPriority, _priorities, (v) => setState(() => _selectedPriority = v!)),
            ] else
              Row(
                children: [
                  Expanded(child: _buildDropdown('Category *', _selectedCategory, _categories, (v) => setState(() => _selectedCategory = v!))),
                  const SizedBox(width: 24),
                  Expanded(child: _buildDropdown('Priority *', _selectedPriority, _priorities, (v) => setState(() => _selectedPriority = v!))),
                ],
              ),
            
            const SizedBox(height: 24),
            _buildField('Subject *', _subjectController, hint: 'Briefly describe your issue', validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 24),
            _buildField('Message *', _messageController, hint: 'Provide detailed information...', maxLines: 6, validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitTicket,
                icon: _isLoading 
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(_isLoading ? 'Submitting...' : 'Submit Ticket', style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  foregroundColor: AppColors.white,
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {String? hint, int maxLines = 1, bool readOnly = false, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.instrumentSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.foreground)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
          validator: validator,
          style: GoogleFonts.instrumentSans(color: AppColors.foreground, fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.instrumentSans(color: AppColors.mutedForeground, fontSize: 14),
            filled: true,
            fillColor: readOnly ? AppColors.muted : AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryPink),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.instrumentSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.foreground)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.white,
              style: GoogleFonts.instrumentSans(color: AppColors.foreground, fontSize: 15, fontWeight: FontWeight.w500),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.instrumentSans(color: AppColors.foreground)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards(bool isMobile, bool isTablet, settings) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: [
        _infoCard(Icons.email_outlined, 'Email Us', settings.contactEmail, 'Send us an email anytime', isMobile),
        _infoCard(Icons.phone_outlined, 'Call Us', settings.contactPhone, 'Mon-Fri from 8am to 6pm', isMobile),
        _infoCard(Icons.location_on_outlined, 'Visit Us', settings.contactAddress, 'CURATO Headquarters', isMobile),
        _infoCard(Icons.access_time_outlined, 'Hours', 'Mon-Fri: 8am-6pm', 'Response in 24h', isMobile),
      ],
    );
  }

  Widget _infoCard(IconData icon, String title, String value, String subtitle, bool isMobile) {
    VoidCallback? onTap;
    if (title == 'Email Us') {
      onTap = _launchEmail;
    } else if (title == 'Call Us') {
      onTap = () => _launchPhone(value);
    } else if (title == 'Visit Us') {
      onTap = _launchMaps;
    }

    Widget card = Container(
      width: isMobile ? double.infinity : 280,
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(border: Border.all(color: AppColors.border),
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: AppColors.muted, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primaryPink, size: 24),
          ),
          const SizedBox(height: 20),
          Text(title, style: GoogleFonts.instrumentSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
          const SizedBox(height: 8),
          Text(value, textAlign: TextAlign.center, style: GoogleFonts.instrumentSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryPink)),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.instrumentSans(fontSize: 12, color: AppColors.mutedForeground)),
        ],
      ),
    );

    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: card,
        ),
      );
    }

    return card;
  }

  Widget _buildFAQSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      decoration: BoxDecoration(border: Border.all(color: AppColors.border),
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text('Frequently Asked Questions', style: GoogleFonts.instrumentSans(fontSize: 24, fontWeight: FontWeight.w400, color: AppColors.foreground), textAlign: TextAlign.center),
          const SizedBox(height: 48),
          if (isMobile)
            Column(
              children: [
                _faqItem('What are your response times?', 'We typically respond to all inquiries within 24 hours.'),
                const SizedBox(height: 32),
                _faqItem('Can I track my ticket status?', 'Yes, you can view your ticket status in your profile or stay tuned for updates via email.'),
                const SizedBox(height: 32),
                _faqItem('How do I return a product?', 'Visit our Returns page or raise a ticket under "Order Support" category.'),
                const SizedBox(height: 32),
                _faqItem('Is phone support available?', 'Yes, our lines are open Monday to Friday from 8 AM to 6 PM.'),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _faqItem('What are your response times?', 'We typically respond to all inquiries within 24 hours.'),
                      const SizedBox(height: 32),
                      _faqItem('Can I track my ticket status?', 'Yes, you can view your ticket status in your profile or stay tuned for updates via email.'),
                    ],
                  ),
                ),
                const SizedBox(width: 64),
                Expanded(
                  child: Column(
                    children: [
                      _faqItem('How do I return a product?', 'Visit our Returns page or raise a ticket under "Order Support" category.'),
                      const SizedBox(height: 32),
                      _faqItem('Is phone support available?', 'Yes, our lines are open Monday to Friday from 8 AM to 6 PM.'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
        const SizedBox(height: 12),
        Text(answer, style: GoogleFonts.instrumentSans(fontSize: 14, color: AppColors.mutedForeground, height: 1.6)),
      ],
    );
  }
}
