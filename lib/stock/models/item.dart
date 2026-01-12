class Item {
  final int? id;
  final String name;
  final String code;
  final int stock;
  final double buyPrice;
  final double sellPrice;
  final int minStock;
  final String? imageUrl;
  final String? category;
  final String createdAt;

  Item({
    this.id,
    required this.name,
    required this.code,
    required this.stock,
    required this.buyPrice,
    required this.sellPrice,
    required this.minStock,
    this.imageUrl,
    this.category,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'stock': stock,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'minStock': minStock,
      'imageUrl': imageUrl,
      'category': category,
      'createdAt': createdAt,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      code: map['code'],
      stock: map['stock'],
      buyPrice: map['buyPrice'],
      sellPrice: map['sellPrice'],
      minStock: map['minStock'],
      imageUrl: map['imageUrl'],
      category: map['category'],
      createdAt: map['createdAt'],
    );
  }
}