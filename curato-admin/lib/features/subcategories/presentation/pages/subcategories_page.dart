import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curato_admin/features/layout/presentation/widgets/admin_layout.dart';
import 'package:curato_admin/features/categories/data/services/category_service.dart';
import 'package:curato_admin/features/subcategories/data/services/subcategory_service.dart';
import 'package:curato_admin/core/services/service_locator.dart';

import 'package:curato_admin/core/constants/app_colors.dart';

class SubcategoriesPage extends StatefulWidget {
  const SubcategoriesPage({super.key});

  @override
  State<SubcategoriesPage> createState() => _SubcategoriesPageState();
}

class _SubcategoriesPageState extends State<SubcategoriesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _subcategories = [];
  List<dynamic> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        sl<SubcategoryService>().getSubcategories(),
        sl<CategoryService>().getCategories(type: 'approved'),
      ]);
      setState(() {
        _subcategories = results[0];
        _categories = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteSubcategory(String id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this subcategory?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await sl<SubcategoryService>().deleteSubcategory(id);
      _fetchData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subcategory deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/subcategories',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sub Categories',
                            style: GoogleFonts.instrumentSans(
                              fontSize: 28,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.5,
                              color: AppColors.foreground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage product sub-categories. ${_subcategories.length} active sub-categories.',
                            style: GoogleFonts.instrumentSans(
                              color: AppColors.mutedForeground,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddSubcategoryDialog,
                        icon: const Icon(Icons.add, size: 20),
                        label: Text(
                          'Add Sub Category',
                          style: GoogleFonts.instrumentSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.foreground,
                          foregroundColor: AppColors.background,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: StadiumBorder(),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Stats Row
                  Row(
                    children: [
                      _buildStatCard('Total Sub Categories', _subcategories.length.toString(), AppColors.foreground),
                      const SizedBox(width: 24),
                      _buildStatCard('Active Sub Categories', _subcategories.where((s) => s['status'] == 'active').length.toString(), AppColors.signal),
                      const SizedBox(width: 24),
                      _buildStatCard('Parent Categories', _categories.length.toString(), AppColors.foreground),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Filter and Search Bar
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: AppColors.mutedForeground, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Search sub-categories...',
                                      hintStyle: GoogleFonts.instrumentSans(
                                        color: AppColors.mutedForeground,
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: 'All Parent Categories',
                              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                              items: ['All Parent Categories'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: GoogleFonts.instrumentSans(
                                      fontSize: 14,
                                      color: AppColors.foreground,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (_) {},
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (_isLoading)
                    const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator()))
                  else if (_subcategories.isEmpty)
                    // Empty State
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 80),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.rotate(
                            angle: -0.2,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.muted,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.local_offer_outlined,
                                size: 48,
                                color: AppColors.border,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No sub-categories found',
                            style: GoogleFonts.instrumentSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.foreground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adding your first sub-category to get started',
                            style: GoogleFonts.instrumentSans(
                              fontSize: 15,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    // Data Table
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(1),
                          3: IntrinsicColumnWidth(),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: AppColors.muted,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            ),
                            children: [
                              _buildTableHeader('Name'),
                              _buildTableHeader('Parent Category'),
                              _buildTableHeader('Status'),
                              _buildTableHeader('Actions'),
                            ],
                          ),
                          ..._subcategories.map((sub) {
                            return TableRow(
                              children: [
                                _buildTableCell(sub['name'] ?? ''),
                                _buildTableCell(sub['category']?['name'] ?? 'N/A'),
                                _buildStatusCell(sub['status'] ?? 'active'),
                                _buildActionCell(sub),
                              ],
                            );
                          }),
                        ],
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

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: GoogleFonts.instrumentSans(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.foreground,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: GoogleFonts.instrumentSans(
          fontSize: 14,
          color: AppColors.foreground,
        ),
      ),
    );
  }

  Widget _buildStatusCell(String status) {
    final isActive = status == 'active';
    return Padding(
      padding: const EdgeInsets.all(16),
      child: UnconstrainedBox(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.signalTint : AppColors.muted,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            isActive ? 'Active' : 'Inactive',
            style: GoogleFonts.instrumentSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.signal : AppColors.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCell(dynamic sub) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.foreground),
            onPressed: () => _showEditSubcategoryDialog(sub),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
            onPressed: () => _deleteSubcategory(sub['_id']),
          ),
        ],
      ),
    );
  }


  void _showEditSubcategoryDialog(dynamic sub) {
    final TextEditingController nameCtrl = TextEditingController(text: sub['name']);
    final TextEditingController descCtrl = TextEditingController(text: sub['description']);
    String? selectedCategoryId = sub['category']?['_id'] ?? sub['category'];
    bool isActive = sub['status'] == 'active';
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: AppColors.background,
              surfaceTintColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Sub Category',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.5,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildLabel('Name'),
                    const SizedBox(height: 8),
                    _buildTextField('Enter sub category name', controller: nameCtrl),
                    const SizedBox(height: 20),
                    
                    _buildLabel('Parent Category'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.foreground, width: 1.5),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCategoryId,
                          hint: Text('Select a parent category', style: GoogleFonts.instrumentSans(color: AppColors.mutedForeground, fontSize: 14)),
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                          items: _categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat['_id'],
                              child: Text(cat['name'] ?? '', style: GoogleFonts.instrumentSans(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (val) => setModalState(() => selectedCategoryId = val),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    _buildLabel('Description'),
                    const SizedBox(height: 8),
                    _buildTextField('Enter sub category description', controller: descCtrl, maxLines: 4),
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: isActive,
                            onChanged: (val) => setModalState(() => isActive = val ?? false),
                            activeColor: AppColors.foreground,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Active',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 14,
                            color: AppColors.foreground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              side: BorderSide(color: AppColors.border),
                              shape: StadiumBorder(),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.instrumentSans(
                                color: AppColors.foreground,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSaving ? null : () async {
                              if (nameCtrl.text.isEmpty || selectedCategoryId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please fill all required fields')),
                                );
                                return;
                              }
                              setModalState(() => isSaving = true);
                              try {
                                await sl<SubcategoryService>().updateSubcategory(sub['_id'], {
                                  'name': nameCtrl.text,
                                  'description': descCtrl.text,
                                  'category': selectedCategoryId,
                                  'status': isActive ? 'active' : 'inactive',
                                });
                                if (context.mounted) Navigator.pop(context);
                                _fetchData();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Subcategory updated successfully')),
                                  );
                                }
                              } catch (e) {
                                setModalState(() => isSaving = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.foreground,
                              foregroundColor: AppColors.background,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: StadiumBorder(),
                              elevation: 0,
                            ),
                            child: isSaving 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.background, strokeWidth: 2))
                              : Text(
                                  'Update',
                                  style: GoogleFonts.instrumentSans(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddSubcategoryDialog() {
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController descCtrl = TextEditingController();
    String? selectedCategoryId;
    bool isActive = true;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: AppColors.background,
              surfaceTintColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Sub Category',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.5,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildLabel('Name'),
                    const SizedBox(height: 8),
                    _buildTextField('Enter sub category name', controller: nameCtrl),
                    const SizedBox(height: 20),

                    _buildLabel('Parent Category'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.foreground, width: 1.5),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCategoryId,
                          hint: Text('Select a parent category', style: GoogleFonts.instrumentSans(color: AppColors.mutedForeground, fontSize: 14)),
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                          items: _categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat['_id'],
                              child: Text(cat['name'] ?? '', style: GoogleFonts.instrumentSans(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (val) => setModalState(() => selectedCategoryId = val),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('Description'),
                    const SizedBox(height: 8),
                    _buildTextField('Enter sub category description', controller: descCtrl, maxLines: 4),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: isActive,
                            onChanged: (val) => setModalState(() => isActive = val ?? false),
                            activeColor: AppColors.foreground,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Active',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 14,
                            color: AppColors.foreground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              side: BorderSide(color: AppColors.border),
                              shape: StadiumBorder(),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.instrumentSans(
                                color: AppColors.foreground,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSaving ? null : () async {
                              if (nameCtrl.text.isEmpty || selectedCategoryId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please fill all required fields')),
                                );
                                return;
                              }
                              setModalState(() => isSaving = true);
                              try {
                                await sl<SubcategoryService>().createSubcategory({
                                  'name': nameCtrl.text,
                                  'description': descCtrl.text,
                                  'category': selectedCategoryId,
                                  'status': isActive ? 'active' : 'inactive',
                                });
                                if (context.mounted) Navigator.pop(context);
                                _fetchData();
                              } catch (e) {
                                setModalState(() => isSaving = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.foreground,
                              foregroundColor: AppColors.background,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: StadiumBorder(),
                              elevation: 0,
                            ),
                            child: isSaving 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.background, strokeWidth: 2))
                              : Text(
                                  'Create',
                                  style: GoogleFonts.instrumentSans(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.instrumentSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.foreground,
      ),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.instrumentSans(color: AppColors.mutedForeground, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.foreground, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.instrumentSans(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.instrumentSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

