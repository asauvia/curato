import 'package:flutter/material.dart';
import 'package:curato_user/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curato_user/core/controllers/home_controller.dart';
import 'package:curato_user/core/utils/url_helper.dart';

class CategorySidebar extends StatelessWidget {
  const CategorySidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: const BoxDecoration(
              color: AppColors.primaryPink, // Match the pinkish header in reference
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.list, color: AppColors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  'All Categories',
                  style: GoogleFonts.instrumentSans(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: HomeController.instance,
              builder: (context, _) {
                final categories = HomeController.instance.categories;

                if (HomeController.instance.isLoading && categories.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryPink,
                      strokeWidth: 2,
                    ),
                  );
                }

                if (categories.isEmpty) {
                  return Center(
                    child: Text(
                      'No categories found',
                      style: GoogleFonts.instrumentSans(
                        color: AppColors.grey,
                        fontSize: 13,
                      ),
                    ),
                  );
                }

                return Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: AppColors.transparent),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: categories.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      indent: 20,
                      endIndent: 20,
                      color: AppColors.muted,
                    ),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final title = category['name'] ?? 'Unknown';
                      final List<dynamic> subcategories =
                          category['subcategories'] ?? [];

                      final String? imageUrl = category['image'];
                      Widget leadingWidget;
                      if (imageUrl != null && imageUrl.isNotEmpty) {
                        leadingWidget = ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            imageUrl,
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.category_outlined,
                              size: 20,
                              color: AppColors.grey,
                            ),
                          ),
                        );
                      } else {
                        leadingWidget = const Icon(
                          Icons.category_outlined,
                          size: 20,
                          color: AppColors.grey,
                        );
                      }

                      if (subcategories.isEmpty) {
                        return ListTile(
                          leading: leadingWidget,
                          title: Text(
                            title,
                            style: GoogleFonts.instrumentSans(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: AppColors.grey,
                          ),
                          onTap: () {
                            final route = UrlHelper.categoryUrl(title, 'All');
                            Navigator.pushNamed(
                              context,
                              route,
                              arguments: {
                                'category': title,
                                'subcategory': 'All',
                              },
                            );
                          },
                          dense: true,
                          hoverColor: AppColors.bgSecondaryLight,
                        );
                      }

                      return ExpansionTile(
                        leading: leadingWidget,
                        title: Text(
                          title,
                          style: GoogleFonts.instrumentSans(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        tilePadding: const EdgeInsets.only(left: 16, right: 16),
                        childrenPadding: const EdgeInsets.only(left: 12),
                        collapsedIconColor: AppColors.grey,
                        iconColor: AppColors.primaryPink,
                        children: subcategories.map((sub) {
                          return ListTile(
                            contentPadding: const EdgeInsets.only(
                              left: 48,
                              right: 16,
                            ),
                            title: Text(
                              sub['name'] ?? '',
                              style: GoogleFonts.instrumentSans(
                                fontSize: 13,
                                color: AppColors.grey600,
                              ),
                            ),
                            onTap: () {
                              final route = UrlHelper.categoryUrl(title, sub['name'] ?? '');
                              Navigator.pushNamed(
                                context,
                                route,
                                arguments: {
                                  'category': title,
                                  'subcategory': sub['name'] ?? '',
                                },
                              );
                            },
                            dense: true,
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
