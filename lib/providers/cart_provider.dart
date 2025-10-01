import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';
import '../models/service_type.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  String? _customerName;
  String? _tableNumber;
  String? _seatNumber;
  ServiceType? _serviceType;

  List<CartItem> get items => List.unmodifiable(_items);
  String? get customerName => _customerName;
  String? get tableNumber => _tableNumber;
  String? get seatNumber => _seatNumber;
  ServiceType? get serviceType => _serviceType;
  int get itemCount {
    try {
      return _items.fold(0, (sum, item) => sum + item.quantity);
    } catch (e) {
      debugPrint('Error calculating item count: $e');
      return 0;
    }
  }

  double get subtotal {
    try {
      return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
    } catch (e) {
      debugPrint('Error calculating subtotal: $e');
      return 0.0;
    }
  }

  double get tax => 0.0; // No tax
  double get serviceCharge => subtotal * 0.10; // 10% service charge
  double get total => subtotal + serviceCharge;
  bool get isEmpty => _items.isEmpty;

  void addItem(
    FoodItem foodItem, {
    int quantity = 1,
    String? specialInstructions,
  }) {
    if (quantity <= 0) return;

    try {
      final existingIndex = _items.indexWhere(
        (item) => item.foodItem.id == foodItem.id,
      );

      if (existingIndex >= 0) {
        _items[existingIndex] = _items[existingIndex].copyWith(
          quantity: _items[existingIndex].quantity + quantity,
        );
      } else {
        _items.add(
          CartItem(
            foodItem: foodItem,
            quantity: quantity,
            specialInstructions: specialInstructions,
          ),
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding item to cart: $e');
    }
  }

  void removeItem(FoodItem foodItem) {
    _items.removeWhere((item) => item.foodItem.id == foodItem.id);
    notifyListeners();
  }

  void removeItemByIndex(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void updateQuantity(FoodItem foodItem, int quantity) {
    try {
      if (quantity <= 0) {
        removeItem(foodItem);
        return;
      }

      final existingIndex = _items.indexWhere(
        (item) => item.foodItem.id == foodItem.id,
      );

      if (existingIndex >= 0) {
        _items[existingIndex] = _items[existingIndex].copyWith(
          quantity: quantity,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating quantity: $e');
    }
  }

  void clearCart() {
    _items.clear();
    _customerName = null;
    _tableNumber = null;
    _seatNumber = null;
    _serviceType = null;
    notifyListeners();
  }

  void setCustomerInfo({
    String? name,
    String? tableNumber,
    String? seatNumber,
  }) {
    _customerName = name;
    _tableNumber = tableNumber;
    _seatNumber = seatNumber;
    notifyListeners();
  }

  void setServiceType(ServiceType? serviceType) {
    _serviceType = serviceType;
    notifyListeners();
  }

  bool get canCreateOrder =>
      !isEmpty &&
      _tableNumber != null &&
      _tableNumber!.isNotEmpty &&
      _seatNumber != null &&
      _seatNumber!.isNotEmpty;

  int getItemQuantity(FoodItem foodItem) {
    try {
      final item = _items.firstWhere((item) => item.foodItem.id == foodItem.id);
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }

  bool isItemInCart(FoodItem foodItem) {
    return _items.any((item) => item.foodItem.id == foodItem.id);
  }
}
