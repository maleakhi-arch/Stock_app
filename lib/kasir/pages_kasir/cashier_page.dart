import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Item: ${cart.totalItems}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// ================= ITEM LIST =================
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 12),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      final outOfStock = item.stock <= 0;

                      return ListTile(
                        tileColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(item.name),
                        subtitle: Text(
                          'Rp ${item.sellPrice.toStringAsFixed(0)} • Stok ${item.stock}',
                          style: TextStyle(
                            color: outOfStock
                                ? Colors.red
                                : Colors.grey.shade700,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle),
                          color: outOfStock ? Colors.grey : Colors.blue,
                          onPressed: outOfStock
                              ? null
                              : () => cart.addItem(item),
                        ),
                      );
                    },
                  ),
                ),

                /// ================= CART =================
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
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
                            return ListTile(
                              title: Text(c.item.name),
                              subtitle: Text(
                                'Rp ${c.item.sellPrice.toStringAsFixed(0)}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () => cart.decreaseQty(c.item),
                                  ),
                                  Text(
                                    c.quantity.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () => cart.increaseQty(c.item),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                      const Divider(),

                      /// ================= PAYMENT =================
                      Text(
                        'Total: Rp ${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        controller: paidController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Uang Dibayar',
                          prefixText: 'Rp ',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Kembalian: Rp ${change < 0 ? 0 : change.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: change < 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: cart.isEmpty
                            ? null
                            : () async {
                                try {
                                  await db.checkoutSale(
                                    cartItems: cart.items,
                                    total: cart.totalPrice,
                                    paid: cart.totalPrice,
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
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
