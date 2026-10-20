import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:curato_user/core/constants/app_colors.dart';
import 'package:curato_user/core/services/api_service.dart';
import 'package:curato_user/core/widgets/curato_layout.dart';
import 'package:curato_user/core/widgets/centered_content.dart';
import 'package:curato_user/core/utils/responsive.dart';
import 'package:curato_user/features/home/domain/models/product_model.dart';
import 'package:curato_user/features/home/presentation/widgets/product_card.dart';

class SharedCollectionPage extends StatefulWidget {
  final String shareCode;

  const SharedCollectionPage({
    super.key,
    required this.shareCode,
  });

  @override
  State<SharedCollectionPage> createState() => _SharedCollectionPageState();
}

class _SharedCollectionPageState extends State<SharedCollectionPage> {
  bool _isLoading = true;
  String? _errorMsg;
  String _collectionName = "Loading Collection...";
  String _collectionDesc = "";
  String? _resellerCode;
  List<ProductModel> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchSharedCollection();
  }

  Future<void> _fetchSharedCollection() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMsg = null;
      });

      final url = Uri.parse('${ApiService.baseUrl}/reseller/shared-collections/${widget.shareCode}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coll = data['collection'];
        final String? resCode = data['resellerCode'];

        final productsList = coll['products'] as List? ?? [];
        final List<ProductModel> loadedProducts = [];

        for (var item in productsList) {
          if (item['product'] != null) {
            loadedProducts.add(ProductModel.fromMap(Map<String, dynamic>.from(item['product'])));
          }
        }

        setState(() {
          _collectionName = coll['name'] ?? "Curated Collection";
          _collectionDesc = coll['description'] ?? "";
          _resellerCode = resCode;
          _products = loadedProducts;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMsg = "Failed to load collection. Status: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = "An error occurred: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    Widget content;

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(color: AppColors.primaryPink),
      );
    } else if (_errorMsg != null) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.primaryPink),
              const SizedBox(height: 16),
              Text(
                _errorMsg!,
                style: GoogleFonts.instrumentSans(fontSize: 16, color: AppColors.mutedForeground),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchSharedCollection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: const StadiumBorder(),
                ),
                child: Text('Retry', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    } else {
      content = SingleChildScrollView(
        child: Container(
          color: AppColors.background,
          padding: EdgeInsets.symmetric(vertical: isMobile ? 32 : 60),
          child: CenteredContent(
            horizontalPadding: isMobile ? 16 : 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Collection Banner Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isMobile ? 24 : 40),
                  decoration: BoxDecoration(
                    color: AppColors.foreground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPink.withOpacity(0.2),
                              border: Border.all(color: AppColors.primaryPink),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'CURATED COLLECTION',
                              style: GoogleFonts.instrumentSans(
                                color: AppColors.primaryPink,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          if (_resellerCode != null) ...[
                            const SizedBox(width: 12),
                            Text(
                              'By Reseller Code: $_resellerCode',
                              style: GoogleFonts.instrumentSans(
                                color: AppColors.mutedForeground,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _collectionName,
                        style: GoogleFonts.instrumentSans(
                          fontSize: isMobile ? 28 : 38,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      if (_collectionDesc.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _collectionDesc,
                          style: GoogleFonts.instrumentSans(
                            fontSize: isMobile ? 14 : 16,
                            color: AppColors.mutedForeground,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 40 : 50),

                // Products Header
                Text(
                  'Products in this Collection (${_products.length})',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w400, letterSpacing: -0.5,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 24),

                if (_products.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Column(
                        children: [
                          const Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.mutedForeground),
                          const SizedBox(height: 16),
                          Text(
                            'This collection does not contain any products.',
                            style: GoogleFonts.instrumentSans(fontSize: 16, color: AppColors.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 2 : (isTablet ? 3 : 4),
                      crossAxisSpacing: isMobile ? 12 : 24,
                      mainAxisSpacing: isMobile ? 12 : 24,
                      mainAxisExtent: isMobile ? 290 : 340,
                    ),
                    itemBuilder: (context, index) {
                      return ProductCard(product: _products[index]);
                    },
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return CuratoLayout(
      activeTitle: 'COLLECTION',
      child: content,
    );
  }
}
