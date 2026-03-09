import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app/kasir/pages_kasir/sales_history_page.dart';
import '../providers/cart_providers.dart';
import '../../stock/database/database_helper.dart';
import '../../stock/models/item.dart';

class CashierPage extends StatefulWidget {
  const CashierPage({super.key});

  @override
  State<CashierPage> createState() => _CashierPageState();
}

class _CashierPageState extends State<CashierPage> {
  final DBHelper db = DBHelper();
  final TextEditingController paidController = TextEditingController();

  List<Item> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    items = await db.getAllItems();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final total = cart.totalPrice;
    final paid = double.tryParse(paidController.text) ?? 0;
    final change = paid - total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SalesHistoryPage()),
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 12),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      final outOfStock = item.stock <= 0;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade50,
                            child: const Icon(
                              Icons.inventory_2,
                              color: Colors.blue,
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Rp ${item.sellPrice.toStringAsFixed(0)} • Stok ${item.stock}",
                            style: TextStyle(
                              color: outOfStock
                                  ? Colors.red
                                  : Colors.grey.shade600,
                            ),
                          ),
                          trailing: CircleAvatar(
                            backgroundColor: outOfStock
                                ? Colors.grey
                                : Colors.blue,
                            child: IconButton(
                              icon: const Icon(Icons.add, color: Colors.white),
                              onPressed: outOfStock
                                  ? null
                                  : () => cart.addItem(item),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Cart',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      if (cart.isEmpty)
                        const Text('Cart kosong')
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cart.items.length,
                          itemBuilder: (context, i) {
                            final c = cart.items[i];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                title: Text(
                                  c.item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  "Rp ${c.item.sellPrice.toStringAsFixed(0)}",
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      onPressed: () => cart.decreaseQty(c.item),
                                    ),
                                    Text(
                                      c.quantity.toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      onPressed: () => cart.increaseQty(c.item),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                      const Divider(),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Total: Rp ${total.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        controller: paidController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Uang Dibayar',
                          prefixText: 'Rp ',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: change < 0
                              ? Colors.red.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Kembalian: Rp ${change < 0 ? 0 : change.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: change < 0 ? Colors.red : Colors.green,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: cart.isEmpty || paid < total
                              ? null
                              : () async {
                                  final paid =
                                      double.tryParse(paidController.text) ?? 0;
                                  if (paid < total) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("uang kurang oyy"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  try {
                                    await db.checkoutSale(
                                      cartItems: cart.items,
                                      total: cart.totalPrice,
                                      paid: paid,
                                    );

                                    cart.clear();
                                    paidController.clear();

                                    if (!mounted) return;
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Transaksi berhasil'),
                                      ),
                                    );

                                    _loadItems(); // refresh stok
                                  } catch (e) {
                                    if (!mounted) return;
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                },
                          child: const Text(
                            'CHECKOUT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
