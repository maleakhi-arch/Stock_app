import 'dart:io';
import 'package:flutter/material.dart';
import '../models/item.dart';

class InfoPage extends StatelessWidget {
  final Item item;

  const InfoPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Barang'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildImage(),
            const SizedBox(height: 20),
            _infoTile('Nama Barang', item.name),
            _infoTile('Kode Barang', item.code),
            _infoTile('Stok Saat Ini', item.stock.toString()),
            _infoTile('Stok Minimum', item.minStock.toString()),
            _infoTile('Harga Beli', 'Rp ${item.buyPrice}'),
            _infoTile('Harga Jual', 'Rp ${item.sellPrice}'),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (item.imageUrl == null || item.imageUrl!.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Icon(Icons.image_not_supported, size: 60)),
      );
    }

    final isNetwork = item.imageUrl!.startsWith('http');

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image(
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        image: isNetwork
            ? NetworkImage(item.imageUrl!)
            : FileImage(File(item.imageUrl!)) as ImageProvider,
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(flex: 6, child: Text(value)),
        ],
      ),
    );
  }
}
