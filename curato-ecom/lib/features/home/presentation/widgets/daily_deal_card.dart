import 'package:flutter/material.dart';
import 'package:curato_user/core/constants/app_colors.dart';
import 'package:curato_user/features/home/domain/models/product_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curato_user/features/cart/application/cart_controller.dart';
import 'package:curato_user/core/controllers/wishlist_controller.dart';
import 'package:curato_user/core/services/session_service.dart';
import 'package:curato_user/features/home/presentation/widgets/cart_drawer.dart';
import 'package:curato_user/core/utils/url_helper.dart';

class DailyDealCard extends StatelessWidget {
  final ProductModel product;

  const DailyDealCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final double progress = (product.sold ?? 0) / ((product.available ?? 1) + (product.sold ?? 0));
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return ListenableBuilder(
      listenable: WishlistController.instance,
      builder: (context, _) {
        final bool isWishlisted = WishlistController.instance.isWishlisted(product.id);
        
        final Widget content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category/Brand Label
            Text(
              (product.brand ?? product.category ?? 'Curato Premium').toUpperCase(),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.mutedForeground,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 5),

            // Product Name
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.instrumentSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 6),

            // Description
            Text(
              product.shortDescription ?? 'Premium quality guaranteed. High durability and modern design.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.instrumentSans(
                color: AppColors.mutedForeground, 
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            
            // Pricing Block
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '₹${product.price.ceil()}',
                  style: GoogleFonts.instrumentSans(
                    color: AppColors.primaryPink,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                if (product.oldPrice != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '₹${product.oldPrice!.ceil()}',
                    style: GoogleFonts.instrumentSans(
                      color: AppColors.mrpBrown,
                      decoration: TextDecoration.lineThrough,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.muted,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPink),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 14),
            
            // Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (!SessionService.instance.isLoggedIn) {
                    CartController.instance.setPendingItem(product.id, product.getEffectiveMoq());
                    Navigator.pushNamed(context, '/login');
                    return;
                  }
                  final success = await CartController.instance.addToCart(product.id);
                  if (context.mounted && success) {
                    CartDrawer.showSlider(context, addedProductName: product.name);
                  }
                },
                icon: const Icon(Icons.shopping_bag_outlined, size: 14, color: AppColors.white),
                label: const Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.foreground,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: const StadiumBorder(),
                  textStyle: GoogleFonts.instrumentSans(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ],
        );

        return InkWell(
          onTap: () {
            final route = UrlHelper.productUrl(product);
            Navigator.pushNamed(
              context,
              route,
              arguments: product,
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.muted, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(isWishlisted),
                const SizedBox(height: 14),
              content,
            ],
          ),
        ));
      },
    );
  }

  Widget _buildImage(bool isWishlisted) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 130,
          decoration: BoxDecoration(border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
            color: AppColors.background,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, _, __) => const Center(
                  child: Icon(Icons.image_not_supported_outlined, size: 36, color: AppColors.mutedForeground),
                ),
              ),
            ),
          ),
        ),
        
        // Discount Badge
        if (product.discount > 0)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.foreground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${product.discount}% OFF',
                style: GoogleFonts.instrumentSans(
                  color: AppColors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          
        // Wishlist Button
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () {
              final productMap = {
                '_id': product.id,
                'name': product.name,
                'price': product.price,
                'images': [product.imageUrl],
              };
              WishlistController.instance.toggleWishlist(productMap);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border_rounded, 
                size: 16, 
                color: isWishlisted ? AppColors.primaryPink : AppColors.mutedForeground,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
