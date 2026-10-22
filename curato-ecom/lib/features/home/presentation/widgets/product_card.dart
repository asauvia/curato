import 'package:flutter/material.dart';
import 'package:curato_user/core/constants/app_colors.dart';
import 'package:curato_user/features/home/domain/models/product_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curato_user/core/controllers/wishlist_controller.dart';
import 'package:curato_user/core/services/session_service.dart';
import 'package:curato_user/features/cart/application/cart_controller.dart';
import 'package:curato_user/features/home/presentation/widgets/cart_drawer.dart';
import 'package:curato_user/core/utils/url_helper.dart';
import 'package:curato_user/core/theme/app_button_styles.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onAddToCart,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: WishlistController.instance,
      builder: (context, _) {
        final bool isWishlisted = WishlistController.instance.isWishlisted(widget.product.id);
        
        return GestureDetector(
          onTap: () {
            final route = UrlHelper.productUrl(
              widget.product,
              refCode: widget.product.resellerCode,
            );
            Navigator.pushNamed(
              context,
              route,
              arguments: widget.product,
            );
          },
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isHovered ? AppColors.primaryBlue : AppColors.borderLight,
                  width: _isHovered ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.network(
                              widget.product.imageUrl,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      if (widget.product.discount > 0)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.oxide,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${widget.product.discount}% OFF',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              isWishlisted ? Icons.favorite : Icons.favorite_border, 
                              size: 20,
                              color: isWishlisted ? AppColors.primaryPink : null,
                            ),
                            onPressed: () {
                              final productMap = {
                                '_id': widget.product.id,
                                'name': widget.product.name,
                                'price': widget.product.price,
                                'images': [widget.product.imageUrl],
                              };
                              WishlistController.instance.toggleWishlist(productMap);
                            },
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.instrumentSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '₹${widget.product.price.ceil()}',
                              style: GoogleFonts.instrumentSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.brass,
                              ),
                            ),
                            if (widget.product.oldPrice != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '₹${widget.product.oldPrice!.ceil()}',
                                style: GoogleFonts.instrumentSans(
                                  fontSize: 14,
                                  color: AppColors.mrpBrown,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 13,
                                  color: (widget.product.available ?? 0) > 0 ? AppColors.signal : AppColors.oxide,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  (widget.product.available ?? 0) > 0 ? 'In Stock' : 'Out of Stock',
                                  style: GoogleFonts.instrumentSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: (widget.product.available ?? 0) > 0 ? AppColors.signal : AppColors.oxide,
                                  ),
                                ),
                              ],
                            ),
                             if (widget.product.getEffectiveMoq() > 1)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.blue50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.blue200),
                                ),
                                child: Text(
                                  'MOQ: ${widget.product.getEffectiveMoq()}',
                                  style: GoogleFonts.instrumentSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.blue700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (!SessionService.instance.isLoggedIn) {
                                CartController.instance.setPendingItem(widget.product.id, widget.product.getEffectiveMoq());
                                Navigator.pushNamed(context, '/login');
                                return;
                              }
                              if (widget.onAddToCart != null) {
                                widget.onAddToCart!();
                              } else {
                                final success = await CartController.instance.addToCart(
                                  widget.product.id,
                                  quantity: widget.product.getEffectiveMoq(),
                                  moq: widget.product.getEffectiveMoq(),
                                );
                                if (context.mounted && success) {
                                  CartDrawer.showSlider(context, addedProductName: widget.product.name);
                                }
                              }
                            },
                            style: AppButtonStyles.brassOutline(),
                            child: Text(
                              'Add to Cart',
                              style: GoogleFonts.instrumentSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
