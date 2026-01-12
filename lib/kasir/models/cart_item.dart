import '../../stock/models/item.dart';

class CartItem {
  final Item item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});

  double get totalPrice {
    return item.sellPrice * quantity;
  }

  double get totalCost {
    return item.buyPrice * quantity;
  }

  double get profit {
    return totalPrice - totalCost;
  }

  void increase() {
    quantity++;
  }

  void decrease() {
    if (quantity > 1) {
      quantity--;
    }
  }
}
