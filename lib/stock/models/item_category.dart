class ItemCategory {
  final String name;
  final String icon;

  const ItemCategory(this.name, this.icon);
}

const List<ItemCategory> categories = [
  ItemCategory('all', '📦'),
  ItemCategory('sembako', '🍚'),
  ItemCategory('makanan', '🍜'),
  ItemCategory('minuman', '🥤'),
  ItemCategory('snack', '🍪'),
  ItemCategory('lainnya', '📁'),
];
