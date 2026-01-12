// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../database/database_helper.dart';
import '../models/item.dart';
import '../service/API_service.dart';

class AddEditItemPage extends StatefulWidget {
  final Item? item;

  const AddEditItemPage({super.key, this.item});

  @override
  State<AddEditItemPage> createState() => _AddEditItemPageState();
}

class _AddEditItemPageState extends State<AddEditItemPage> {
  final _formKey = GlobalKey<FormState>();
  final db = DBHelper();
  final apiService = ApiService();

  String selectedCategory = 'lainnya';

  final List<String> categories = [
    'all',
    'sembako',
    'makanan',
    'minuman',
    'snack',
    'lainnya',
  ];

  late TextEditingController nameController;
  late TextEditingController codeController;
  late TextEditingController stockController;
  late TextEditingController buyController;
  late TextEditingController sellController;
  late TextEditingController minStockController;

  bool isCodeUnique = true;
  bool isLoading = false;

  String? imagePath;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    nameController = TextEditingController(text: item?.name ?? '');
    codeController = TextEditingController(text: item?.code ?? '');
    stockController = TextEditingController(
      text: item?.stock.toString() ?? '0',
    );
    buyController = TextEditingController(
      text: item?.buyPrice.toString() ?? '0',
    );
    sellController = TextEditingController(
      text: item?.sellPrice.toString() ?? '0',
    );
    minStockController = TextEditingController(
      text: item?.minStock.toString() ?? '0',
    );

    imagePath = item?.imageUrl;
    selectedCategory = item?.category ?? 'sembako';
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    stockController.dispose();
    buyController.dispose();
    sellController.dispose();
    minStockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (picked != null) {
      setState(() {
        imagePath = picked.path;
      });
    }
  }

  Future<void> checkCodeUnique(String code) async {
    final database = await db.db;
    final result = await database.query(
      'items',
      where: 'code = ?',
      whereArgs: [code],
    );

    setState(() {
      isCodeUnique = result.isEmpty;
    });
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    final newItem = Item(
      id: widget.item?.id,
      name: nameController.text.trim(),
      code: codeController.text.trim(),
      stock: int.tryParse(stockController.text.trim()) ?? 0,
      buyPrice: double.tryParse(buyController.text.trim()) ?? 0,
      sellPrice: double.tryParse(sellController.text.trim()) ?? 0,
      minStock: int.tryParse(minStockController.text.trim()) ?? 0,
      imageUrl: imagePath,
      category: selectedCategory,
    );

    try {
      if (widget.item == null) {
        await db.insertItem(newItem);
        print('Barang baru disimpan: ${newItem.name}');
      } else {
        await db.updateItem(newItem);
        print('Barang diperbarui: ${newItem.name}');
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      print('Error saat menyimpan item: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
      }
    }
  }

  Future<void> _fetchProductFromAPI() async {
    final barcode = codeController.text.trim();

    if (barcode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan kode/barcode terlebih dahulu!')),
      );
      return;
    }

    setState(() => isLoading = true);

    final product = await apiService.getProductByBarcode(barcode);

    setState(() => isLoading = false);

    if (product != null) {
      setState(() {
        nameController.text = product['product_name'] ?? '';
        final energyValue = product['nutriments']?['energy-kcal_100g'];
        sellController.text = energyValue != null
            ? energyValue.toString()
            : '0';
        imagePath = product['image_url'];
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data produk berhasil diambil dari API!')),
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk tidak ditemukan di API')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Barang' : 'Tambah Barang'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: nameController,
                label: 'Nama Barang',
                icon: Icons.inventory_2_outlined,
                validator: (val) =>
                    val!.trim().isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: codeController,
                label: 'Kode Barang',
                icon: Icons.qr_code_2,
                errorText: isCodeUnique ? null : 'Kode sudah dipakai!',
                onChanged: checkCodeUnique,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _fetchProductFromAPI,
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.cloud_download, size: 18),
                  label: const Text('Ambil dari API'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: stockController,
                label: 'Stok Yang dibeli',
                icon: Icons.layers_outlined,
                keyboardType: TextInputType.number,
                validator: (val) => int.tryParse(val ?? '') == null
                    ? 'Masukkan angka valid'
                    : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: buyController,
                      label: 'Harga Beli',
                      icon: Icons.shopping_cart_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      controller: sellController,
                      label: 'Harga Jual',
                      icon: Icons.attach_money_rounded,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: minStockController,
                label: 'Stok Minimum (Notifikasi)',
                icon: Icons.warning_amber_rounded,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: selectedCategory,
                items: categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(14),
                    image: imagePath != null
                        ? DecorationImage(
                            image: imagePath!.startsWith('http')
                                ? NetworkImage(imagePath!)
                                : FileImage(File(imagePath!)) as ImageProvider,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imagePath == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40),
                            SizedBox(height: 8),
                            Text('Tambah Gambar'),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: isCodeUnique ? _saveItem : null,
                  icon: const Icon(Icons.save),
                  label: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Barang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        labelText: label,
        errorText: errorText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}
