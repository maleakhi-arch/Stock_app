import 'package:flutter/material.dart';
import '../../stock/database/database_helper.dart';

class SalesHistoryPage extends StatefulWidget {
  const SalesHistoryPage({super.key});

  @override
  State<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends State<SalesHistoryPage> {

  final DBHelper db = DBHelper();
  List<Map<String, dynamic>> sales = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadSales();
  }

  Future<void> loadSales() async {
    sales = await db.getSales();
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Transaksi"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : sales.isEmpty
              ? const Center(child: Text("Belum ada transaksi"))
              : ListView.builder(
                  itemCount: sales.length,
                  itemBuilder: (context, i) {

                    final s = sales[i];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(
                          "Rp ${s['total'].toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          s['timestamp'],
                        ),
                        trailing: const Icon(Icons.receipt_long),
                      ),
                    );
                  },
                ),
    );
  }
}