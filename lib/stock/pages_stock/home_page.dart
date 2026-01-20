import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/item.dart';
import 'add_item_page.dart';
import 'stock_history_page.dart';
import '../widget/item_card.dart';
import '../service/csv_export_service.dart';
import 'info_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DBHelper db = DBHelper();
  final TextEditingController _searchController = TextEditingController();
  final CsvExportService csvService = CsvExportService();

  List<Item> items = [];
  String searchQuery = '';
  bool showLowStockOnly = false;
  String selectedCategory = 'all';

  final List<String> categories = [
    'all',
    'sembako',
    'makanan',
    'minuman',
    'snack',
    'lainnya',
  ];

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    final result = await db.getItemsByCategory(
      category: selectedCategory,
      query: searchQuery.isEmpty ? null : searchQuery,
      lowStockOnly: showLowStockOnly,
    );

    setState(() {
      items = result;
    });
  }

  Future<void> _openAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditItemPage()),
    );
    if (result == true) loadItems();
  }

  Future<void> _openEdit(Item item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditItemPage(item: item)),
    );
    if (result == true) loadItems();
  }

  void _openHistory(Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StockHistoryPage(item: item)),
    );
  }

  void _openInfo(Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => InfoPage(item: item)),
    );
  }

  Future<void> _deleteItem(Item item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin menghapus barang ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await db.deleteItem(item.id!);
      loadItems();
    }
  }

  Future<void> _exportCSV() async {
    final path = await csvService.exportItemsToCSV(items);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(
      // ignore: use_build_context_synchronously
      context,
    ).showSnackBar(SnackBar(content: Text('Data berhasil diexport ke: $path')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), 
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          "Stock Manager",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: loadItems,
          ),
          IconButton(
            icon: Icon(
              showLowStockOnly
                  ? Icons.warning_amber
                  : Icons.warning_amber_outlined,
              color: showLowStockOnly ? Colors.orangeAccent : Colors.black,
            ),
            onPressed: () {
              setState(() {
                showLowStockOnly = !showLowStockOnly;
                if (showLowStockOnly) {
                  _searchController.clear();
                  searchQuery = '';
                }
              });
              loadItems();
            },
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.black),
            onPressed: _exportCSV,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    searchQuery = value;
                    loadItems();
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau kode barang...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              searchQuery = '';
                              loadItems();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isActive = cat == selectedCategory;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isActive,
                        onSelected: (_) {
                          setState(() {
                            selectedCategory = cat;
                          });
                          loadItems();
                        },
                        selectedColor: Colors.blueAccent,
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: TextStyle(
                          color: isActive ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                'Belum ada barang yang anda masukkan 😔',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ItemCard(
                  item: item,
                  onEdit: () => _openEdit(item),
                  onDelete: () => _deleteItem(item),
                  onHistory: () => _openHistory(item),
                  onChangeStock: (change, note) async {
                    await db.changeStock(
                      itemId: item.id!,
                      change: change,
                      note: note,
                    );
                    loadItems();
                  },
                  onInfo: () => _openInfo(item),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
