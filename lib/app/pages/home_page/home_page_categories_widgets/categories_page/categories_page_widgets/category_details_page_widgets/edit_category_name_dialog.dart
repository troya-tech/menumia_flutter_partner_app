import 'package:flutter/material.dart';
import 'package:menumia_flutter_partner_app/app/theme/app_colors.dart';
import 'package:menumia_flutter_partner_app/features/menu/domain/entities/category.dart';

class EditCategoryNameDialog extends StatefulWidget {
  final Category category;
  final ValueChanged<String> onSave;

  const EditCategoryNameDialog({
    super.key,
    required this.category,
    required this.onSave,
  });

  @override
  State<EditCategoryNameDialog> createState() => _EditCategoryNameDialogState();
}

class _EditCategoryNameDialogState extends State<EditCategoryNameDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shadowColor: Colors.black.withOpacity(0.2),
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      actionsPadding: const EdgeInsets.all(20),
      title: const Row(
        children: [
          Icon(Icons.edit_rounded, color: AppColors.brightBlue, size: 28),
          SizedBox(width: 12),
          Text(
            'Kategori Düzenle',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            _buildTextField(
              controller: _nameController,
              label: 'Kategori Adı',
              prefixIcon: Icons.category_rounded,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                child: const Text(
                  'İptal',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brightBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Kaydet',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    bool autoFocus = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          autofocus: autoFocus,
          decoration: InputDecoration(
            prefixIcon: Icon(prefixIcon, color: AppColors.brightBlue.withOpacity(0.7), size: 20),
            hintText: '$label giriniz',
            hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.4)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.brightBlue, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSave() {
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty && newName != widget.category.name) {
      widget.onSave(newName);
    }
    Navigator.pop(context);
  }
}
