import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/utils/money.dart';
import 'package:kapdakhata/core/utils/validators.dart';
import 'package:kapdakhata/core/widgets/k_buttons.dart';
import 'package:kapdakhata/core/widgets/k_cards.dart';
import 'package:kapdakhata/shared/providers/app_providers.dart';
import 'package:kapdakhata/shared/repositories/repositories.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key, this.productId});

  final int? productId;

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sizeController = TextEditingController();
  final _colorController = TextEditingController();
  final _costController = TextEditingController();
  final _sellingController = TextEditingController();
  final _stockController = TextEditingController();
  final _skuController = TextEditingController();
  final _notesController = TextEditingController();

  int? _selectedCategoryId;
  String? _photoPath;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);
    final db = ref.read(databaseProvider);
    final item = await db.getProductWithCategory(widget.productId!);
    if (item != null && mounted) {
      _nameController.text = item.product.name;
      _selectedCategoryId = item.product.typeId;
      _sizeController.text = item.product.size ?? '';
      _colorController.text = item.product.color ?? '';
      _costController.text = (item.product.costPricePaise / 100).toString();
      _sellingController.text =
          (item.product.sellingPricePaise / 100).toString();
      _stockController.text = item.product.stockQuantity.toString();
      _skuController.text = item.product.sku ?? '';
      _notesController.text = item.product.notes ?? '';
      _photoPath = item.product.photoPath;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  int get _costPaise =>
      Money.fromRupeesString(_costController.text).paise;

  int get _sellingPaise =>
      Money.fromRupeesString(_sellingController.text).paise;

  int get _profitPaise => _sellingPaise - _costPaise;

  Future<void> _pickImage(ImageSource source) async {
    final path = await ref
        .read(imageServiceProvider)
        .pickImage(source, context: context);
    if (path != null) setState(() => _photoPath = path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(productRepositoryProvider);
      final cost = _costPaise;
      final selling = _sellingPaise;
      final stock = int.tryParse(_stockController.text.trim()) ?? 0;

      if (widget.productId != null) {
        await repo.updateProduct(
          id: widget.productId!,
          name: _nameController.text.trim(),
          typeId: _selectedCategoryId!,
          size: _sizeController.text.trim().isEmpty
              ? null
              : _sizeController.text.trim(),
          color: _colorController.text.trim().isEmpty
              ? null
              : _colorController.text.trim(),
          photoPath: _photoPath,
          costPricePaise: cost,
          sellingPricePaise: selling,
          stockQuantity: stock,
          sku: _skuController.text.trim().isEmpty
              ? null
              : _skuController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
      } else {
        await repo.createProduct(
          name: _nameController.text.trim(),
          typeId: _selectedCategoryId!,
          size: _sizeController.text.trim().isEmpty
              ? null
              : _sizeController.text.trim(),
          color: _colorController.text.trim().isEmpty
              ? null
              : _colorController.text.trim(),
          photoPath: _photoPath,
          costPricePaise: cost,
          sellingPricePaise: selling,
          stockQuantity: stock,
          sku: _skuController.text.trim().isEmpty
              ? null
              : _skuController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.productId != null
                  ? 'Product updated'
                  : 'Product saved',
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    _colorController.dispose();
    _costController.dispose();
    _sellingController.dispose();
    _stockController.dispose();
    _skuController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(productCategoriesProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.productId != null ? 'Edit Product' : 'Add Product'),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryPurple),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId != null ? 'Edit Product' : 'Add Product'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: GestureDetector(
                onTap: () => _showPhotoOptions(),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.purpleSubtle,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _photoPath != null
                      ? Image.file(File(_photoPath!), fit: BoxFit.cover)
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, color: AppColors.primaryPurple),
                            SizedBox(height: 4),
                            Text(
                              'Add Photo',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primaryPurple,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Product Name *'),
              validator: (v) => Validators.required(v, field: 'Product name'),
            ),
            const SizedBox(height: 16),
            categories.when(
              data: (cats) => DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Type *'),
                items: cats
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
                validator: (v) => v == null ? 'Type is required' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Failed to load categories'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sizeController,
              decoration: const InputDecoration(
                labelText: 'Size',
                hintText: 'S / M / L / XL',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(labelText: 'Color'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _costController,
              decoration: const InputDecoration(labelText: 'Cost Price *'),
              keyboardType: TextInputType.number,
              validator: Validators.nonNegativeAmount,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sellingController,
              decoration: const InputDecoration(labelText: 'Selling Price *'),
              keyboardType: TextInputType.number,
              validator: Validators.nonNegativeAmount,
              onChanged: (_) => setState(() {}),
            ),
            if (_costController.text.isNotEmpty &&
                _sellingController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              KProfitCard(profitPaise: _profitPaise),
              if (_profitPaise < 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Selling below cost. Expected loss: ${MoneyFormatter.format(_profitPaise.abs())}',
                  style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                ),
              ],
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(labelText: 'Stock Quantity'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _skuController,
              decoration: const InputDecoration(labelText: 'SKU / Product Code'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            KPrimaryButton(
              label: 'Save Product',
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_photoPath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _photoPath = null);
                },
              ),
          ],
        ),
      ),
    );
  }
}
