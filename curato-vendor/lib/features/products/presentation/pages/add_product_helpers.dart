part of 'add_product_page.dart';



extension AddProductHelpers on _AddProductPageState {
  // ── Helpers ────────────────────────────────────────────────────

  Widget _card({
    String? note,
    required String title,
    required Widget child,
    Widget? trailing,
    bool required = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (note != null && note.isNotEmpty) ...[
            Text(
              note,
              style: GoogleFonts.instrumentSans(
                fontSize: 13,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  text: title,
                  style: GoogleFonts.instrumentSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  children: required
                      ? [
                          TextSpan(
                            text: ' *',
                            style: GoogleFonts.instrumentSans(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ]
                      : [],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _fieldLabel(String label, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: GoogleFonts.instrumentSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary),
        children: required
            ? [
                TextSpan(
                  text: ' *',
                  style:
                      GoogleFonts.instrumentSans(color: Colors.red, fontSize: 13),
                )
              ]
            : [],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      enabled: enabled,
      style: GoogleFonts.instrumentSans(fontSize: 13, color: enabled ? AppColors.textPrimary : AppColors.textLight),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.instrumentSans(fontSize: 13, color: AppColors.textLight),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: enabled ? AppColors.surface : AppColors.muted,
      ),
    );
  }

  Widget _dropdownField({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final uniqueItems = items.toSet().toList();
    final safeValue = (value != null && uniqueItems.contains(value)) ? value : null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.surface,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          dropdownColor: AppColors.surface,
          hint: Text(hint,
              style: GoogleFonts.instrumentSans(
                  fontSize: 13, color: AppColors.textLight)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          style:
              GoogleFonts.instrumentSans(fontSize: 13, color: AppColors.textPrimary),
          items: uniqueItems
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _uploadBox({
    required double width,
    required double height,
    required String? label,
    XFile? imageFile,
    String? imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          border: Border.all(
              color: AppColors.border,
              style: BorderStyle.solid,
              width: 1.5),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.background,
        ),
        child: imageFile != null
            ? (kIsWeb 
                ? Image.network(imageFile.path, fit: BoxFit.cover)
                : Image.file(io.File(imageFile.path), fit: BoxFit.cover))
            : imageUrl != null
            ? Image.network(imageUrl, fit: BoxFit.cover)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_outlined,
                      size: 24, color: AppColors.textLight),
                  if (label != null) ...[
                    const SizedBox(height: 4),
                    Text(label,
                        style: GoogleFonts.instrumentSans(
                            fontSize: 12, color: AppColors.textLight)),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.instrumentSans(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _infoText(String text) {
    return Row(
      children: [
        Icon(Icons.info_outline, size: 13, color: Colors.blue.shade400),
        const SizedBox(width: 4),
        Text(text,
            style: GoogleFonts.instrumentSans(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _attrCheckbox(
      String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: Checkbox(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: GoogleFonts.instrumentSans(
                fontSize: 13, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _selectionField({
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppColors.surface,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          style: GoogleFonts.instrumentSans(fontSize: 13, color: AppColors.textPrimary),
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
