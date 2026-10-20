import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:curato_admin/features/products/data/models/product_model.dart';
import 'package:curato_admin/core/services/product_service.dart';
import 'package:curato_admin/core/services/service_locator.dart';

import 'package:curato_admin/core/constants/app_colors.dart';

class ProductDetailsDialog extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onRefresh;

  const ProductDetailsDialog({
    super.key,
    required this.product,
    this.onRefresh,
  });

  @override
  State<ProductDetailsDialog> createState() => _ProductDetailsDialogState();
}

class _ProductDetailsDialogState extends State<ProductDetailsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedImageIndex = 0;
  late List<String> _selectedPages;
  bool _isSavingPages = false;

  final List<String> _availablePages = const [
    'Shop',
    'Home',
    'Features',
    'Deals',
    'Trending',
    'Daily Deals',
    'Just For You',
    'Latest Products',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedPages = List<String>.from(widget.product.showOnPages);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _savePageVisibility() async {
    setState(() => _isSavingPages = true);
    try {
      await sl<ProductService>().updateProductShowOnPages(
        widget.product.id,
        _selectedPages,
      );

      // Update local object to reflect the saved state immediately
      widget.product.showOnPages.clear();
      widget.product.showOnPages.addAll(_selectedPages);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product page visibility updated successfully!'),
          ),
        );
      }
      if (widget.onRefresh != null) {
        widget.onRefresh!();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating visibility: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingPages = false);
      }
    }
  }

  Future<void> _launchURL(String urlString) async {
    final url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch $urlString: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 1100 ? 1000.0 : screenWidth * 0.9;
    final dialogHeight = MediaQuery.of(context).size.height * 0.85;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: AppColors.background,
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        color: AppColors.muted,
        child: Column(
          children: [
            // Header
            _buildHeader(p),

            // Tab bar
            Container(
              color: AppColors.background,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.foreground,
                labelColor: AppColors.foreground,
                unselectedLabelColor: AppColors.mutedForeground,
                labelStyle: GoogleFonts.instrumentSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                unselectedLabelStyle: GoogleFonts.instrumentSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: 'OVERVIEW'),
                  Tab(text: 'VARIATIONS & SPECS'),
                  Tab(text: 'FINANCIALS & MOQ'),
                  Tab(text: 'SEO & METADATA'),
                ],
              ),
            ),

            // Tab Body
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(p),
                  _buildVariationsTab(p),
                  _buildFinancialsTab(p),
                  _buildSeoTab(p),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ProductModel p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: AppColors.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: GoogleFonts.instrumentSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.foreground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${p.id}',
                        style: GoogleFonts.instrumentSans(
                          color: AppColors.mutedForeground,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _buildStatusChip(p.status),
                const SizedBox(width: 8),
                _buildVisibilityChip(p.visibility),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppColors.mutedForeground),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ProductModel p) {
    final images = p.images.isNotEmpty ? p.images : [p.image];
    final hasImages = images.isNotEmpty && images[0].isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Media Gallery
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Image View
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: hasImages
                        ? Image.network(
                            images[_selectedImageIndex],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: AppColors.muted,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 48,
                                    color: AppColors.border,
                                  ),
                                ),
                          )
                        : Container(
                            color: AppColors.muted,
                            child: Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: AppColors.border,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // Thumbnails
                if (images.length > 1)
                  SizedBox(
                    height: 60,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final isSelected = index == _selectedImageIndex;
                        return InkWell(
                          onTap: () =>
                              setState(() => _selectedImageIndex = index),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.foreground
                                    : AppColors.border,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                images[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(color: AppColors.muted),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),

                // Descriptions
                _buildCardSection(
                  title: 'Description',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (p.shortDescription != null &&
                          p.shortDescription!.isNotEmpty) ...[
                        Text(
                          'Short Description',
                          style: GoogleFonts.instrumentSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p.shortDescription!,
                          style: GoogleFonts.instrumentSans(
                            fontSize: 13,
                            color: AppColors.mutedForeground,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        'Full Description',
                        style: GoogleFonts.instrumentSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p.fullDescription != null &&
                                p.fullDescription!.isNotEmpty
                            ? p.fullDescription!
                            : 'No full description provided.',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 13,
                          color: AppColors.mutedForeground,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),

          // Right Side: Vendor & Meta summary
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vendor details card
                _buildVendorCard(p.vendor),
                const SizedBox(height: 20),

                // Logistics / Dimensions
                _buildCardSection(
                  title: 'Dimensions & Logistics',
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Weight',
                        p.weight != null && p.weight! > 0
                            ? '${p.weight} kg'
                            : 'Not specified',
                        icon: Icons.scale,
                      ),
                      const Divider(height: 16),
                      _buildInfoRow(
                        'Dimensions',
                        (p.length != null && p.length! > 0) ||
                                (p.width != null && p.width! > 0) ||
                                (p.height != null && p.height! > 0)
                            ? '${p.length ?? 0} x ${p.width ?? 0} x ${p.height ?? 0} cm (L x W x H)'
                            : 'Not specified',
                        icon: Icons.straighten,
                      ),
                      const Divider(height: 16),
                      _buildInfoRow(
                        'Shipping Required',
                        p.requiresShipping ? 'Yes' : 'No',
                        icon: Icons.local_shipping,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Category detail card
                _buildCardSection(
                  title: 'Categorization',
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Category',
                        p.category,
                        icon: Icons.category,
                      ),
                      const Divider(height: 16),
                      _buildInfoRow(
                        'Sub-Category',
                        p.subCategory ?? '-',
                        icon: Icons.subdirectory_arrow_right,
                      ),
                      const Divider(height: 16),
                      _buildInfoRow('Brand', p.brand, icon: Icons.copyright),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariationsTab(ProductModel p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Attributes
          _buildCardSection(
            title: 'Configured Attributes',
            child: Row(
              children: [
                _buildAttributeBadge('Size', p.attributes.size),
                const SizedBox(width: 12),
                _buildAttributeBadge('Color', p.attributes.color),
                const SizedBox(width: 12),
                _buildAttributeBadge('Material', p.attributes.material),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Variations Table
          _buildCardSection(
            title: 'Product Variations',
            child: p.variations.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'This product has no variations.',
                        style: GoogleFonts.instrumentSans(
                          color: AppColors.mutedForeground,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        color: AppColors.muted,
                        child: Row(
                          children: [
                            Expanded(flex: 3, child: _tableHeader('VARIANT')),
                            Expanded(flex: 2, child: _tableHeader('SKU')),
                            Expanded(flex: 2, child: _tableHeader('PRICE')),
                            Expanded(
                              flex: 1,
                              child: _tableHeader(
                                'STOCK',
                                align: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: p.variations.length,
                        separatorBuilder: (context, index) =>
                            Divider(color: AppColors.border, height: 1),
                        itemBuilder: (context, index) {
                          final v = p.variations[index];
                          // Build labels description
                          List<String> labelParts = [];
                          if (v.size != null && v.size!.isNotEmpty)
                            labelParts.add('Size: ${v.size}');
                          if (v.color != null && v.color!.isNotEmpty)
                            labelParts.add('Color: ${v.color}');
                          if (v.material != null && v.material!.isNotEmpty)
                            labelParts.add('Material: ${v.material}');
                          final variantLabel = labelParts.isEmpty
                              ? 'Default Variant'
                              : labelParts.join(' | ');

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    variantLabel,
                                    style: GoogleFonts.instrumentSans(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    v.sku ?? '-',
                                    style: GoogleFonts.instrumentSans(
                                      fontSize: 12,
                                      color: AppColors.mutedForeground,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '₹${v.price.toStringAsFixed(0)}',
                                    style: GoogleFonts.instrumentSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.foreground,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '${v.stock}',
                                    textAlign: TextAlign.end,
                                    style: GoogleFonts.instrumentSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: v.stock <= 5
                                          ? Colors.red
                                          : AppColors.signal,
                                    ),
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
          const SizedBox(height: 24),

          // Technical Specifications
          _buildCardSection(
            title: 'Technical Specifications',
            child: p.specifications == null || p.specifications!.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'No technical specifications available.',
                        style: GoogleFonts.instrumentSans(
                          color: AppColors.mutedForeground,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                : Table(
                    columnWidths: const {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(7),
                    },
                    border: TableBorder.all(
                      color: AppColors.muted,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                    children: p.specifications!.map((spec) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              spec.key,
                              style: GoogleFonts.instrumentSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppColors.foreground,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              spec.value,
                              style: GoogleFonts.instrumentSans(
                                fontSize: 12,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialsTab(ProductModel p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pricing Breakdown
          Expanded(
            flex: 5,
            child: Column(
              children: [
                _buildCardSection(
                  title: 'Pricing & Margins',
                  child: Column(
                    children: [
                      _buildFinancialRow(
                        'MRP',
                        p.oldPrice != null
                            ? '₹${p.oldPrice!.toStringAsFixed(2)}'
                            : '₹${p.price.toStringAsFixed(2)}',
                      ),
                      const Divider(height: 16),
                      _buildFinancialRow(
                        'Vendor Cost Price',
                        p.originalPrice != null
                            ? '₹${p.originalPrice!.toStringAsFixed(2)}'
                            : 'Not specified',
                        isCost: true,
                      ),
                      const Divider(height: 16),
                      _buildFinancialRow(
                        'Commission Percent',
                        p.commissionPercent != null
                            ? '${p.commissionPercent}%'
                            : '0.00%',
                        isCommission: true,
                      ),
                      const Divider(height: 16),
                      _buildFinancialRow(
                        'Commission Amount',
                        p.commissionAmount != null
                            ? '₹${p.commissionAmount!.toStringAsFixed(2)}'
                            : '₹0.00',
                        isCommission: true,
                      ),
                      const Divider(height: 16),
                      _buildFinancialRow(
                        'Admin Net Selling Price',
                        p.sellingPrice != null
                            ? '₹${p.sellingPrice!.toStringAsFixed(2)}'
                            : '₹${p.price.toStringAsFixed(2)}',
                        isPrimary: true,
                      ),
                      const Divider(height: 16),
                      _buildFinancialRow(
                        'Customer Display Price',
                        '₹${p.price.toStringAsFixed(2)}',
                        isPrimary: true,
                      ),
                      if (p.discount > 0) ...[
                        const Divider(height: 16),
                        _buildFinancialRow(
                          'Discount Offered by Vendor',
                          '${p.discount}% OFF (Save ₹${((p.oldPrice ?? p.price) - p.price).toStringAsFixed(2)})',
                          isPrimary: false,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildCardSection(
                  title: 'GST Details',
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'GST Rate',
                        p.gst != null ? '${p.gst}%' : '0%',
                        icon: Icons.percent,
                      ),
                      const Divider(height: 16),
                      _buildInfoRow(
                        'HSN Code',
                        p.hsnCode ?? 'Not specified',
                        icon: Icons.description_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),

          // Inventory & Quantity Constraints
          Expanded(
            flex: 5,
            child: Column(
              children: [
                _buildCardSection(
                  title: 'Inventory Status',
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Total Stock Available',
                        '${p.stock}',
                        icon: Icons.inventory_2,
                      ),
                      const Divider(height: 16),
                      _buildInfoRow(
                        'Low Stock Alert Threshold',
                        '${p.lowStockThreshold}',
                        icon: Icons.warning_amber_rounded,
                      ),
                      const Divider(height: 16),
                      _buildInfoRow(
                        'Track Quantity Level',
                        p.trackQuantity ? 'Yes' : 'No',
                        icon: Icons.check_circle_outline,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildCardSection(
                  title: 'Order Limits & MOQ',
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Minimum Order Qty (MOQ)',
                        '${p.moq}',
                        icon: Icons.shopping_bag_outlined,
                      ),
                      const Divider(height: 16),
                      _buildInfoRow(
                        'MOQ Bulk Discount',
                        p.moqDiscount > 0 ? '${p.moqDiscount}%' : 'No discount',
                        icon: Icons.discount_outlined,
                      ),
                      if (p.moqTiers.isNotEmpty) ...[
                        const Divider(height: 16),
                        _buildInfoRow(
                          'MOQ Tiered Discounts',
                          p.moqTiers,
                          icon: Icons.playlist_add_check_circle_outlined,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeoTab(ProductModel p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SEO Panel
          _buildCardSection(
            title: 'Search Engine Optimization (SEO)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextMetadataBlock('SEO Meta Title', p.seoTitle ?? p.name),
                const SizedBox(height: 16),
                _buildTextMetadataBlock(
                  'SEO Meta Description',
                  p.seoDescription ?? 'No custom SEO description set.',
                ),
                const SizedBox(height: 16),
                _buildTextMetadataBlock(
                  'Friendly URL Slug',
                  p.slug ?? 'Not generated',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Extra details
          _buildCardSection(
            title: 'Extra Information',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'YouTube Video Link',
                  p.youtubeLink ?? 'None',
                  icon: Icons.video_collection_outlined,
                  action: p.youtubeLink != null && p.youtubeLink!.isNotEmpty
                      ? IconButton(
                          onPressed: () => _launchURL(p.youtubeLink!),
                          icon: const Icon(
                            Icons.open_in_new,
                            size: 18,
                            color: AppColors.foreground,
                          ),
                        )
                      : null,
                ),
                const Divider(height: 16),
                Text(
                  'Search Tags',
                  style: GoogleFonts.instrumentSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                p.tags == null || p.tags!.isEmpty
                    ? Text(
                        'No search tags specified.',
                        style: GoogleFonts.instrumentSans(
                          color: AppColors.mutedForeground,
                          fontSize: 13,
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: p.tags!.map((t) {
                          return Chip(
                            label: Text(
                              t,
                              style: GoogleFonts.instrumentSans(fontSize: 12),
                            ),
                            backgroundColor: AppColors.muted,
                            side: BorderSide.none,
                          );
                        }).toList(),
                      ),
                const Divider(height: 16),
                Text(
                  'Page Visibility Listings',
                  style: GoogleFonts.instrumentSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availablePages.map((page) {
                    final isSelected = _selectedPages.any(
                      (p) => p.toLowerCase() == page.toLowerCase(),
                    );
                    return FilterChip(
                      label: Text(
                        page,
                        style: GoogleFonts.instrumentSans(
                          fontSize: 12,
                          color: AppColors.foreground,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedPages.add(page);
                          } else {
                            _selectedPages.removeWhere(
                              (p) => p.toLowerCase() == page.toLowerCase(),
                            );
                          }
                        });
                      },
                      selectedColor: AppColors.border,
                      backgroundColor: AppColors.muted,
                      checkmarkColor: AppColors.foreground,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _isSavingPages ? null : _savePageVisibility,
                  icon: _isSavingPages
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.background,
                          ),
                        )
                      : const Icon(Icons.save_outlined, size: 16),
                  label: const Text('Save Page Visibility'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.foreground,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: StadiumBorder(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection({required String title, required Widget child}) {
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
          Text(
            title,
            style: GoogleFonts.instrumentSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildVendorCard(VendorModel? vendor) {
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
              Icon(Icons.storefront, color: AppColors.foreground, size: 22),
              const SizedBox(width: 10),
              Text(
                'Vendor Details',
                style: GoogleFonts.instrumentSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (vendor == null)
            Text(
              'No vendor details (Admin uploaded product).',
              style: GoogleFonts.instrumentSans(
                color: AppColors.mutedForeground,
                fontSize: 13,
              ),
            )
          else ...[
            _buildInfoRow(
              'Shop Name',
              vendor.shopName ?? 'Direct Store',
              icon: Icons.shopify,
            ),
            const Divider(height: 16),
            _buildInfoRow(
              'Owner Name',
              vendor.name,
              icon: Icons.person_outline,
            ),
            const Divider(height: 16),
            _buildInfoRow(
              'Email Address',
              vendor.email,
              icon: Icons.mail_outline,
              action: IconButton(
                onPressed: () => _launchURL('mailto:${vendor.email}'),
                icon: const Icon(Icons.mail, size: 18, color: AppColors.foreground),
              ),
            ),
            if (vendor.mobile != null && vendor.mobile!.isNotEmpty) ...[
              const Divider(height: 16),
              _buildInfoRow(
                'Phone Number',
                vendor.mobile!,
                icon: Icons.phone_outlined,
                action: IconButton(
                  onPressed: () => _launchURL('tel:${vendor.mobile!}'),
                  icon: const Icon(Icons.phone, size: 18, color: AppColors.foreground),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    required IconData icon,
    Widget? action,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.mutedForeground),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.instrumentSans(
                  color: AppColors.mutedForeground,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.instrumentSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.foreground,
                ),
              ),
            ],
          ),
        ),
        ?action,
      ],
    );
  }

  Widget _buildFinancialRow(
    String label,
    String value, {
    bool isCost = false,
    bool isCommission = false,
    bool isPrimary = false,
  }) {
    Color valColor = AppColors.foreground;
    if (isCost) {
      valColor = AppColors.mutedForeground;
    } else if (isCommission) {
      valColor = AppColors.foreground;
    } else if (isPrimary) {
      valColor = AppColors.foreground;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.instrumentSans(
            fontSize: 13,
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
            color: isPrimary ? AppColors.foreground : AppColors.mutedForeground,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.instrumentSans(
            fontSize: isPrimary ? 15 : 13,
            fontWeight: FontWeight.bold,
            color: valColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTextMetadataBlock(String label, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.instrumentSans(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: AppColors.mutedForeground,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: GoogleFonts.instrumentSans(
              fontSize: 13,
              color: AppColors.foreground,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeBadge(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.signalTint : AppColors.muted,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: active ? AppColors.signal : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle_outline : Icons.highlight_off,
            size: 16,
            color: active ? AppColors.signal : AppColors.mutedForeground,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.instrumentSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.signal : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final s = status.toUpperCase();
    final isActive = s == 'ACTIVE';
    final isInactive = s == 'INACTIVE';

    Color chipColor;
    Color borderColor;
    Color dotColor;
    Color textColor;

    if (isActive) {
      chipColor = AppColors.signalTint;
      borderColor = AppColors.signal;
      dotColor = AppColors.signal;
      textColor = AppColors.signal;
    } else if (isInactive) {
      chipColor = AppColors.muted;
      borderColor = AppColors.border;
      dotColor = AppColors.mutedForeground;
      textColor = AppColors.mutedForeground;
    } else {
      chipColor = AppColors.muted;
      borderColor = AppColors.border;
      dotColor = AppColors.mutedForeground;
      textColor = AppColors.mutedForeground;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: GoogleFonts.instrumentSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityChip(String visibility) {
    final isPublic = visibility.toLowerCase() == 'public';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isPublic ? AppColors.signalTint : AppColors.muted,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isPublic ? AppColors.signal : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPublic ? Icons.visibility : Icons.visibility_off,
            size: 12,
            color: isPublic ? AppColors.signal : AppColors.foreground,
          ),
          const SizedBox(width: 6),
          Text(
            visibility,
            style: GoogleFonts.instrumentSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isPublic ? AppColors.signal : AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String title, {TextAlign align = TextAlign.start}) {
    return Text(
      title,
      textAlign: align,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.mutedForeground,
        letterSpacing: 0.8,
      ),
    );
  }
}
