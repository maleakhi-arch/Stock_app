import 'package:flutter/material.dart';
import '../models/item.dart';

class ItemCard extends StatefulWidget {
  final Item item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onHistory;
  final VoidCallback onInfo;
  final Function(int change, String note) onChangeStock;

  const ItemCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onHistory,
    required this.onInfo,
    required this.onChangeStock,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0.65, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(curve: Curves.easeOut, parent: _controller));

    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(curve: Curves.easeOut, parent: _controller));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final bool isLowStock = item.stock <= item.minStock;

    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: CustomPaint(
          painter: LowStockGlowPainter(showGlow: isLowStock),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                int change = 0;
                final noteController = TextEditingController();

                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  builder: (context) {
                    return StatefulBuilder(builder: (context, setModalState) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Ubah Stok untuk ${item.name}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () =>
                                      setModalState(() => change--),
                                ),
                                Text('$change',
                                    style: const TextStyle(fontSize: 20)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () =>
                                      setModalState(() => change++),
                                ),
                              ],
                            ),
                            TextField(
                              controller: noteController,
                              decoration: const InputDecoration(
                                labelText: 'Catatan perubahan',
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                if (change != 0 ||
                                    noteController.text.isNotEmpty) {
                                  widget.onChangeStock(
                                      change, noteController.text);
                                }
                                Navigator.pop(context);
                              },
                              child: const Text('Simpan'),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    });
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              isLowStock ? Colors.red[100] : Colors.green[100],
                          child: Icon(
                            isLowStock
                                ? Icons.warning_amber
                                : Icons.inventory_2,
                            color:
                                isLowStock ? Colors.redAccent : Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isLowStock ? 'Stok menipis!' : 'Stok cukup',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color:
                                isLowStock ? Colors.redAccent : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Kode: ${item.code}'),
                          Text(
                              'Stok: ${item.stock} | Min: ${item.minStock}'),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'edit') widget.onEdit();
                        if (value == 'history') widget.onHistory();
                        if (value == 'delete') widget.onDelete();
                        if (value == 'info') widget.onInfo();
                      },
                      itemBuilder: (context) => [
                        _menu(Icons.edit, 'Edit', 'edit', Colors.blue),
                        _menu(Icons.history, 'Riwayat Stok', 'history',
                            Colors.orange),
                        _menu(Icons.delete, 'Hapus', 'delete',
                            Colors.redAccent),
                        _menu(Icons.info, 'Info', 'info', Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _menu(
      IconData ic, String t, String val, Color c) {
    return PopupMenuItem(
      value: val,
      child: Row(children: [
        Icon(ic, size: 18, color: c),
        const SizedBox(width: 8),
        Text(t, style: TextStyle(color: c)),
      ]),
    );
  }
}

class LowStockGlowPainter extends CustomPainter {
  final bool showGlow;
  LowStockGlowPainter({required this.showGlow});

  @override
  void paint(Canvas canvas, Size size) {
    if (!showGlow) return;
    final paint = Paint()
      // ignore: deprecated_member_use
      ..color = Colors.red.withOpacity(0.45)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(3, 0), Offset(3, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}