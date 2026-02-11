import 'package:flutter/material.dart';
import 'package:menumia_flutter_partner_app/app/theme/app_colors.dart';
import 'package:menumia_flutter_partner_app/features/menu/domain/entities/product.dart';

class EditProductDialog extends StatefulWidget {
  final Product product;
  final Function(String name, double price, String description) onSave;

  const EditProductDialog({
    super.key,
    required this.product,
    required this.onSave,
  });

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toStringAsFixed(2));
    _descriptionController = TextEditingController(text: widget.product.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
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
          Icon(Icons.edit_note_rounded, color: AppColors.brightBlue, size: 28),
          SizedBox(width: 12),
          Text(
            'Ürünü Düzenle',
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
              label: 'Ürün Adı',
              autoFocus: true,
              prefixIcon: Icons.restaurant_menu_rounded,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _priceController,
              label: 'Fiyat (₺)',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.payments_rounded,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _descriptionController,
              label: 'Açıklama',
              maxLines: 3,
              prefixIcon: Icons.description_rounded,
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
    TextInputType keyboardType = TextInputType.text,
    bool autoFocus = false,
    int maxLines = 1,
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
          keyboardType: keyboardType,
          autofocus: autoFocus,
          maxLines: maxLines,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim().replaceAll(',', '.');
    final description = _descriptionController.text.trim();
    
    final price = double.tryParse(priceText);

    if (name.isNotEmpty && price != null) {
      widget.onSave(name, price, description);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli isim ve fiyat giriniz'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      );
    }
  }
}
