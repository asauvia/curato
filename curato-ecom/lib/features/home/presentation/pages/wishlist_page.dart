import 'package:curato_user/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curato_user/core/widgets/curato_layout.dart';
import 'package:curato_user/core/widgets/centered_content.dart';
import 'package:curato_user/core/controllers/wishlist_controller.dart';
import 'package:curato_user/features/cart/application/cart_controller.dart';
import 'package:curato_user/core/services/api_service.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CuratoLayout(
      activeTitle: 'WISHLIST',
      child: Container(
        color: AppColors.background,
        child: CenteredContent(
          child: ListenableBuilder(
            listenable: WishlistController.instance,
            builder: (context, _) {
              final items = WishlistController.instance.wishlistItems;
              final isLoading = WishlistController.instance.isLoading;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  
                  // Header
                  Text(
                    'My Wishlist',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Save items for later and never lose track of what you love',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 16,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  if (isLoading)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(100.0),
                      child: CircularProgressIndicator(color: AppColors.primaryPink),
                    ))
                  else if (items.isEmpty)
                    _buildEmptyState(context)
                  else
                    _buildWishlistGrid(context, items),

                  const SizedBox(height: 120),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          Icon(
            Icons.favorite_border_rounded,
            size: 150,
            color: AppColors.mutedForeground.withOpacity(0.5),
          ),
          const SizedBox(height: 48),
          Text(
            'Your wishlist is empty',
            style: GoogleFonts.instrumentSans(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start adding items you love to keep track of them',
            style: GoogleFonts.instrumentSans(
              fontSize: 16,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPink,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Start Shopping',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistGrid(BuildContext context, List<dynamic> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.7,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final product = items[index];
        return _WishlistItemCard(product: product);
      },
    );
  }
}

class _WishlistItemCard extends StatelessWidget {
  final dynamic product;
  const _WishlistItemCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColors.border),
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  ApiService.formatImageUrl(
                    product['images'] != null && product['images'].isNotEmpty 
                        ? product['images'][0] 
                        : (product['image'] ?? '')
                  ),
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: CircleAvatar(
                    backgroundColor: AppColors.white,
                    child: IconButton(
                      icon: const Icon(Icons.favorite, color: AppColors.primaryPink),
                      onPressed: () => WishlistController.instance.removeFromWishlist(product['_id']),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info Section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'] ?? 'Product Name',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.foreground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${product['price'] ?? 0}',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryPink,
                        ),
                      ),
                    ],
                  ),
                    SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        final productId = product['_id'];
                        if (productId == null) return;

                        // 1. Add to Cart
                        final success = await CartController.instance.addToCart(productId);
                        
                        if (success) {
                          // 2. Remove from Wishlist
                          await WishlistController.instance.removeFromWishlist(productId);
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product['name'] ?? 'Item'} moved to cart!'),
                                backgroundColor: AppColors.signal,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to add to cart. Please check your connection.'),
                                backgroundColor: AppColors.errorRed,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryPink),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        'Move to Cart',
                        style: GoogleFonts.instrumentSans(
                          color: AppColors.primaryPink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
