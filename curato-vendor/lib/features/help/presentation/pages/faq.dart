import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curato_vendor/core/constants/app_colors.dart';
import 'package:curato_vendor/core/widgets/sidebar_layout.dart';
import 'package:curato_vendor/core/widgets/vendor_topbar.dart';
import '../../data/services/faq_vendor_service.dart';
import '../../data/services/resource_vendor_service.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final FaqVendorService _faqService = FaqVendorService();
  final ResourceVendorService _resourceService = ResourceVendorService();
  late Future<List<dynamic>> _faqsFuture;
  late Future<List<dynamic>> _resourcesFuture;
  final TextEditingController _faqSearchController = TextEditingController();
  String _faqSearch = '';
  String _selectedCategory = 'All';
  int _activeTab = 0; // 0: FAQs, 1: Videos, 2: Documents

  @override
  void initState() {
    super.initState();
    _faqsFuture = _faqService.getVendorFaqs();
    _resourcesFuture = _resourceService.getVendorResources();
  }

  Widget _buildTabButton(int index, String title) {
    final isActive = _activeTab == index;
    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.instrumentSans(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w600,
            color: isActive ? AppColors.surface : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SidebarLayout(
      activeRoute: '/faq',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const VendorTopBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vendor FAQ & Learning Center',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w400, letterSpacing: -0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find quick answers, watch tutorial videos, or download guides regarding account & operations.',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 16,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Custom Tabs Selector
              Row(
                children: [
                  _buildTabButton(0, '📚 Questions & FAQs'),
                  const SizedBox(width: 16),
                  _buildTabButton(1, '📹 Video Tutorials'),
                  const SizedBox(width: 16),
                  _buildTabButton(2, '📄 Document & Blog Guides'),
                ],
              ),
              const SizedBox(height: 32),

              if (_activeTab == 0) ...[
                // FAQ Container Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Browse All Questions',
                            style: GoogleFonts.instrumentSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Container(
                            width: 340,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _faqSearch.isNotEmpty ? AppColors.primary : AppColors.border),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: AppColors.primary, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _faqSearchController,
                                    onChanged: (v) => setState(() => _faqSearch = v.trim()),
                                    decoration: InputDecoration(
                                      hintText: 'Type keywords (e.g. weight, payout)...',
                                      hintStyle: GoogleFonts.instrumentSans(color: AppColors.textLight, fontSize: 13),
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                if (_faqSearch.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      _faqSearchController.clear();
                                      setState(() => _faqSearch = '');
                                    },
                                    child: Icon(Icons.close, color: AppColors.textLight, size: 16),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      FutureBuilder<List<dynamic>>(
                        future: _faqsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                          }

                          final allFaqs = snapshot.data ?? [];
                          if (allFaqs.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  children: [
                                    Icon(Icons.quiz_outlined, size: 48, color: AppColors.border),
                                    const SizedBox(height: 12),
                                    Text('No FAQs published yet', style: GoogleFonts.instrumentSans(color: AppColors.textSecondary, fontSize: 14)),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Extract unique categories
                          final categoriesSet = <String>{'All'};
                          for (final f in allFaqs) {
                            final cat = f['category']?.toString().trim();
                            if (cat != null && cat.isNotEmpty) categoriesSet.add(cat);
                          }
                          final categories = categoriesSet.toList();

                          // Filter logic by category and search text
                          final filteredFaqs = allFaqs.where((f) {
                            final String q = (f['question'] ?? '').toString().toLowerCase();
                            final String a = (f['answer'] ?? '').toString().toLowerCase();
                            final String cat = (f['category'] ?? 'General').toString();

                            final matchesCategory = _selectedCategory == 'All' || cat == _selectedCategory;
                            final matchesSearch = _faqSearch.isEmpty ||
                                q.contains(_faqSearch.toLowerCase()) ||
                                a.contains(_faqSearch.toLowerCase()) ||
                                cat.toLowerCase().contains(_faqSearch.toLowerCase());

                            return matchesCategory && matchesSearch;
                          }).toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category Filter Chips
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: categories.map((cat) {
                                  final isSelected = _selectedCategory == cat;
                                  return ChoiceChip(
                                    label: Text(cat, style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
                                    selected: isSelected,
                                    selectedColor: AppColors.primary.withOpacity(0.12),
                                    backgroundColor: AppColors.muted,
                                    labelStyle: TextStyle(color: isSelected ? AppColors.primary : AppColors.textSecondary),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                                    ),
                                    onSelected: (selected) {
                                      if (selected) setState(() => _selectedCategory = cat);
                                    },
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),

                              // Results count banner when searching
                              if (_faqSearch.isNotEmpty || _selectedCategory != 'All')
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Showing ${filteredFaqs.length} result(s)',
                                        style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                                      ),
                                      if (_faqSearch.isNotEmpty) ...[
                                        Text(' for "', style: GoogleFonts.instrumentSans(fontSize: 13, color: AppColors.textSecondary)),
                                        Text(_faqSearch, style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                        Text('"', style: GoogleFonts.instrumentSans(fontSize: 13, color: AppColors.textSecondary)),
                                      ],
                                      const Spacer(),
                                      InkWell(
                                        onTap: () {
                                          _faqSearchController.clear();
                                          setState(() {
                                            _faqSearch = '';
                                            _selectedCategory = 'All';
                                          });
                                        },
                                        child: Text(
                                          'Clear Filters',
                                          style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              if (filteredFaqs.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(40),
                                    child: Column(
                                      children: [
                                        Icon(Icons.search_off, size: 44, color: AppColors.border),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No FAQs found matching "$_faqSearch"',
                                          style: GoogleFonts.instrumentSans(color: AppColors.textSecondary, fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('Try searching with different keywords', style: GoogleFonts.instrumentSans(color: AppColors.textLight, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filteredFaqs.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final faq = filteredFaqs[index];
                                    final String id = faq['_id'] ?? index.toString();
                                    final String question = faq['question'] ?? '';
                                    final String answer = faq['answer'] ?? '';
                                    final String category = faq['category'] ?? 'General';
                                    final bool shouldExpand = _faqSearch.isNotEmpty;

                                    return Container(
                                      key: ValueKey('faq_${id}_${_faqSearch}_$_selectedCategory'),
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: shouldExpand ? AppColors.primary.withOpacity(0.4) : AppColors.border),
                                      ),
                                      child: Theme(
                                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                        child: ExpansionTile(
                                          initiallyExpanded: shouldExpand,
                                          iconColor: AppColors.primary,
                                          collapsedIconColor: AppColors.textSecondary,
                                          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                          title: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.purple.shade50,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  category.toUpperCase(),
                                                  style: GoogleFonts.instrumentSans(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.purple.shade700),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  question,
                                                  style: GoogleFonts.instrumentSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                                ),
                                              ),
                                            ],
                                          ),
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                              child: Text(
                                                answer,
                                                style: GoogleFonts.instrumentSans(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],

              if (_activeTab == 1 || _activeTab == 2)
                FutureBuilder<List<dynamic>>(
                  future: _resourcesFuture,
                  builder: (context, resSnapshot) {
                    if (resSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
                    }
                    final resources = resSnapshot.data ?? [];
                    if (resources.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(Icons.video_library_outlined, size: 48, color: AppColors.border),
                              const SizedBox(height: 12),
                              Text('No resources published yet', style: GoogleFonts.instrumentSans(color: AppColors.textSecondary, fontSize: 14)),
                            ],
                          ),
                        ),
                      );
                    }

                    final videos = resources.where((r) => r['type'] == 'VIDEO').toList();
                    final pdfs = resources.where((r) => r['type'] == 'PDF').toList();
                    final blogs = resources.where((r) => r['type'] == 'BLOG').toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_activeTab == 1) ...[
                          if (videos.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  children: [
                                    Icon(Icons.videocam_off_outlined, size: 48, color: AppColors.border),
                                    const SizedBox(height: 12),
                                    Text('No video tutorials found.', style: GoogleFonts.instrumentSans(color: AppColors.textSecondary, fontSize: 14)),
                                  ],
                                ),
                              ),
                            )
                          else
                            ..._buildResourceGroup(
                              '📹 Video Tutorials',
                              videos,
                              Colors.red.shade50,
                              Colors.red.shade700,
                              Icons.play_circle_outline,
                              isVideo: true,
                            ),
                        ],
                        if (_activeTab == 2) ...[
                          if (pdfs.isEmpty && blogs.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  children: [
                                    Icon(Icons.folder_off_outlined, size: 48, color: AppColors.border),
                                    const SizedBox(height: 12),
                                    Text('No document guides found.', style: GoogleFonts.instrumentSans(color: AppColors.textSecondary, fontSize: 14)),
                                  ],
                                ),
                              ),
                            )
                          else ...[
                            if (pdfs.isNotEmpty) ..._buildResourceGroup(
                              '📄 PDF Guides',
                              pdfs,
                              Colors.blue.shade50,
                              Colors.blue.shade700,
                              Icons.picture_as_pdf_outlined,
                            ),
                            if (blogs.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              ..._buildResourceGroup(
                                '📝 Blog Articles',
                                blogs,
                                Colors.green.shade50,
                                Colors.green.shade700,
                                Icons.article_outlined,
                              ),
                            ],
                          ],
                        ],
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Extract YouTube video ID from full URL
  String? _extractYoutubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    return uri.queryParameters['v'];
  }

  List<Widget> _buildResourceGroup(
    String title,
    List<dynamic> items,
    Color bgColor,
    Color accentColor,
    IconData icon, {
    bool isVideo = false,
  }) {
    return [
      Text(title, style: GoogleFonts.instrumentSans(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      const SizedBox(height: 12),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 380,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: isVideo ? 1.1 : 2.0,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final r = items[i];
          final String url = r['url'] ?? '';
          final String videoId = isVideo ? (_extractYoutubeId(url) ?? '') : '';
          final String thumbUrl = videoId.isNotEmpty
              ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'
              : '';

          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isVideo && thumbUrl.isNotEmpty)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                        child: Image.network(
                          thumbUrl,
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 110,
                            color: AppColors.muted,
                            child: Icon(Icons.videocam_off_outlined, color: AppColors.textLight, size: 32),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                            color: AppColors.textPrimary.withOpacity(0.18),
                          ),
                          child: const Icon(Icons.play_circle_fill, color: AppColors.surface, size: 40),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: Icon(icon, color: accentColor, size: 22),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((r['category'] ?? '').toString().isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(r['category'].toString().toUpperCase(), style: GoogleFonts.instrumentSans(fontSize: 9, fontWeight: FontWeight.w600, color: accentColor)),
                        ),
                      Text(
                        r['title'] ?? '',
                        style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((r['description'] ?? '').toString().isNotEmpty) ...[  
                        const SizedBox(height: 4),
                        Text(
                          r['description'],
                          style: GoogleFonts.instrumentSans(fontSize: 11, color: AppColors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          if (r['type'] == 'BLOG') {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        r['title'] ?? '',
                                        style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w600, fontSize: 18),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => Navigator.pop(ctx),
                                    ),
                                  ],
                                ),
                                content: SizedBox(
                                  width: 600,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if ((r['category'] ?? '').toString().isNotEmpty) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: bgColor,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              r['category'].toString().toUpperCase(),
                                              style: GoogleFonts.instrumentSans(fontSize: 10, fontWeight: FontWeight.w600, color: accentColor),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                        Text(
                                          r['content'] ?? r['description'] ?? 'No content available.',
                                          style: GoogleFonts.instrumentSans(fontSize: 14, height: 1.6, color: AppColors.textPrimary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // Open URL — use url_launcher if available, else show snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Open: $url'),
                                action: SnackBarAction(label: 'Copy', onPressed: () {}),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: accentColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(isVideo ? Icons.play_arrow : Icons.open_in_new, size: 14, color: accentColor),
                              const SizedBox(width: 6),
                              Text(
                                isVideo ? 'Watch Video' : r['type'] == 'PDF' ? 'Open PDF' : 'Read Article',
                                style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w600, color: accentColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ];
  }
}