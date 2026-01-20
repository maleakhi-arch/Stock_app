import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/item.dart';
import '../models/stock_history.dart';
import '../../kasir/models/cart_item.dart';
import '../../bagian_luar/notification_service.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'stock_app.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  // ================= CREATE TABLE =================

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
    CREATE TABLE items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      code TEXT NOT NULL UNIQUE,
      stock INTEGER NOT NULL,
      buyPrice REAL NOT NULL,
      sellPrice REAL NOT NULL,
      minStock INTEGER DEFAULT 0,
      imageUrl TEXT,
      category TEXT,
      createdAt TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE sales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      total REAL NOT NULL,
      paid REAL NOT NULL,
      change REAL NOT NULL,
      timestamp TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE sale_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      saleId INTEGER NOT NULL,
      itemId INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      sellPrice REAL NOT NULL,
      buyPrice REAL NOT NULL,
      FOREIGN KEY (saleId) REFERENCES sales(id) ON DELETE CASCADE,
      FOREIGN KEY (itemId) REFERENCES items(id)
    )
  ''');

    await db.execute('''
    CREATE TABLE stock_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      itemId INTEGER NOT NULL,
      saleId INTEGER,
      change INTEGER NOT NULL,
      note TEXT NOT NULL,
      resultingStock INTEGER NOT NULL,
      timestamp TEXT NOT NULL,
      FOREIGN KEY (itemId) REFERENCES items(id),
      FOREIGN KEY (saleId) REFERENCES sales(id)
    )
  ''');
  }

  // ================= UPGRADE =================

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE items ADD COLUMN imageUrl TEXT');
      await db.execute('ALTER TABLE items ADD COLUMN category TEXT');
      await db.execute('''
       CREATE TABLE sales (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       total REAL NOT NULL,
       timestamp TEXT NOT NULL
       )
       ''');
      await db.execute('''
       CREATE TABLE sale_items (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       saleId INTEGER NOT NULL,
       itemId INTEGER NOT NULL,
       quantity INTEGER NOT NULL,
       buyPrice REAL NOT NULL,
       )
       ''');
    }
  }

  // ================= CRUD =================

  Future<int> insertItem(Item item) async {
    final database = await db;
    return await database.insert(
      'items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateItem(Item item) async {
    final database = await db;
    return await database.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id) async {
    final database = await db;

    await database.delete(
      'stock_history',
      where: 'itemId = ?',
      whereArgs: [id],
    );

    return await database.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Item>> getAllItems({String? query}) async {
    final database = await db;

    if (query == null || query.trim().isEmpty) {
      final result = await database.query('items');
      return result.map((e) => Item.fromMap(e)).toList();
    }

    final q = '%${query.trim()}%';
    final result = await database.query(
      'items',
      where: 'name LIKE ? OR code LIKE ?',
      whereArgs: [q, q],
    );

    return result.map((e) => Item.fromMap(e)).toList();
  }

  Future<List<Item>> getLowStockItems() async {
    final database = await db;
    final result = await database.rawQuery(
      'SELECT * FROM items WHERE stock <= minStock',
    );

    return result.map((e) => Item.fromMap(e)).toList();
  }

  Future<List<Item>> getItemsByCategory({
    required String category,
    String? query,
    bool lowStockOnly = false,
  }) async {
    final database = await db;

    final where = <String>[];
    final args = <dynamic>[];

    if (category != 'all') {
      where.add('category = ?');
      args.add(category);
    }

    if (query != null && query.isNotEmpty) {
      where.add('(name LIKE ? OR code LIKE ?)');
      args.add('%$query%');
      args.add('%$query%');
    }

    if (lowStockOnly) {
      where.add('stock <= minStock');
    }

    final result = await database.query(
      'items',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
    );

    return result.map((e) => Item.fromMap(e)).toList();
  }

  Future<void> changeStock({
    required int itemId,
    required int change,
    required String note,
  }) async {
    final database = await db;

    final itemRes = await database.query(
      'items',
      where: 'id = ?',
      whereArgs: [itemId],
    );

    if (itemRes.isEmpty) {
      throw Exception('Barang tidak ditemukan');
    }

    final item = Item.fromMap(itemRes.first);
    final newStock = item.stock + change;

    if (newStock < 0) {
      throw Exception('Stok tidak boleh negatif');
    }

    await database.update(
      'items',
      {'stock': newStock},
      where: 'id = ?',
      whereArgs: [itemId],
    );

    await database.insert('stock_history', {
      'itemId': itemId,
      'change': change,
      'note': note,
      'resultingStock': newStock,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<StockHistory>> getHistoryForItem(int itemId) async {
    final database = await db;
    final result = await database.query(
      'stock_history',
      where: 'itemId = ?',
      whereArgs: [itemId],
      orderBy: 'id DESC',
    );

    return result.map((e) => StockHistory.fromMap(e)).toList();
  }

  Future<void> checkoutSale({
  required List<CartItem> cartItems,
  required double total,
  required double paid,
}) async {
  final database = await db;

  if (paid < total) {
    throw Exception('Uang tidak cukup');
  }

  final change = paid - total;

  await database.transaction((txn) async {
    final saleId = await txn.insert('sales', {
      'total': total,
      'paid': paid,
      'change': change,
      'timestamp': DateTime.now().toIso8601String(),
    });

    for (final c in cartItems) {
      final res = await txn.query(
        'items',
        where: 'id = ?',
        whereArgs: [c.item.id],
      );

      if (res.isEmpty) {
        throw Exception('Barang tidak ditemukan');
      }

      final item = Item.fromMap(res.first);

      if (item.stock < c.quantity) {
        throw Exception('Stok ${item.name} tidak cukup');
      }

      final newStock = item.stock - c.quantity;

      await txn.update(
        'items',
        {'stock': newStock},
        where: 'id = ?',
        whereArgs: [item.id],
      );

      await txn.insert('sale_items', {
        'saleId': saleId,
        'itemId': item.id,
        'quantity': c.quantity,
        'sellPrice': item.sellPrice,
        'buyPrice': item.buyPrice,
      });

      await txn.insert('stock_history', {
        'itemId': item.id,
        'saleId': saleId,
        'change': -c.quantity,
        'note': 'Penjualan',
        'resultingStock': newStock,
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (newStock <= item.minStock) {
        await NotificationService().showLowStockNotification(
          id: item.id!,
          itemName: item.name,
          stock: newStock,
        );
      }
    }
  });
}
}
