import 'package:southsea_cinema/models/basket_item.dart';

class BasketRepository {
  BasketRepository._internal();

  static final BasketRepository instance = BasketRepository._internal();

  final List<BasketItem> _items = [];

  List<BasketItem> getItems() {
    return List<BasketItem>.unmodifiable(_items);
  }

  void addItem(BasketItem item) {
    _items.add(item);
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
    }
  }

  int getTotalItems() {
    int total = 0;
    for (final BasketItem item in _items) {
      total += item.quantity;
    }
    return total;
  }

  int get totalItemCount {
    return getTotalItems();
  }

  double getSubtotal() {
    double sum = 0.0;
    for (final BasketItem item in _items) {
      sum += item.lineTotal;
    }
    return sum;
  }

  double getServiceCharge() {
    if (_items.isEmpty) {
      return 0.0;
    }
    return 4.00;
  }

  double getTotalDue() {
    return getSubtotal() + getServiceCharge();
  }

  void clear() {
    _items.clear();
  }
}
