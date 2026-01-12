import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../../stock/models/item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  void addItem(Item item) {
    final index = _items.indexWhere((c) => c.item.id == item.id);

    if (index >= 0) {
      _items[index].increase();
    } else {
      _items.add(CartItem(item: item));
    }

    notifyListeners();
  }

  void removeItem(Item item) {
    _items.removeWhere((c) => c.item.id == item.id);
    notifyListeners();
  }

  void increaseQty(Item item) {
    final cartItem = _items.firstWhere((c) => c.item.id == item.id);
    cartItem.increase();
    notifyListeners();
  }

  void decreaseQty(Item item) {
    final cartItem = _items.firstWhere((c) => c.item.id == item.id);
    if (cartItem.quantity > 1) {
      cartItem.decrease();
    } else {
      _items.remove(cartItem);
    }

    notifyListeners();
  }

  double get totalPrice {
    return _items.fold(0, (sum, c) => sum + c.totalPrice);
  }

  double get totalProfit {
    return _items.fold(0, (sum, c) => sum + c.profit);
  }

  int get totalItems {
    return _items.fold(0, (sum, c) => sum + c.quantity);
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  bool get isEmpty => _items.isEmpty;
}
