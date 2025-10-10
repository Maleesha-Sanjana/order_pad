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
  String? _existingReceiptNo; // For adding items to existing orders
  int _existingItemsCount = 0; // Track how many items are from existing order

  List<CartItem> get items => List.unmodifiable(_items);
  String? get customerName => _customerName;
  String? get tableNumber => _tableNumber;
  String? get seatNumber => _seatNumber;
  ServiceType? get serviceType => _serviceType;
  String? get existingReceiptNo => _existingReceiptNo;
  int get existingItemsCount => _existingItemsCount;

  // Get only new items (items added after existing items)
  List<CartItem> get newItems =>
      _existingItemsCount > 0 && _items.length > _existingItemsCount
      ? _items.sublist(_existingItemsCount)
      : (_existingItemsCount == 0 ? _items : []);
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
  double get serviceCharge => 0.0; // No service charge
  double get total =>
      subtotal; // Total is just the subtotal without service charge
  bool get isEmpty => _items.isEmpty;

  void addItem(
    FoodItem foodItem, {
    int quantity = 1,
    String? specialInstructions,
    bool isExisting =
        false, // Mark if this is a previously confirmed order (read-only)
  }) {
    if (quantity <= 0) return;

    try {
      // ALWAYS ADD AS NEW ITEM - NEVER COMBINE
      // Each order should be a separate row in the database
      // This allows tracking individual orders separately and preserves order history
      _items.add(
        CartItem(
          foodItem: foodItem,
          quantity: quantity,
          specialInstructions: specialInstructions,
          isExisting: isExisting, // Set the read-only flag
        ),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding item to cart: $e');
    }
  }

  void removeItem(FoodItem foodItem) {
    // Only remove non-existing items (new items that can be deleted)
    // Existing items are locked and shouldn't be removed
    _items.removeWhere(
      (item) => item.foodItem.id == foodItem.id && !item.isExisting,
    );
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

      // Only update non-existing items (new items that can be edited)
      // Existing items are locked and shouldn't be modified
      final existingIndex = _items.indexWhere(
        (item) => item.foodItem.id == foodItem.id && !item.isExisting,
      );

      if (existingIndex >= 0) {
        _items[existingIndex] = _items[existingIndex].copyWith(
          quantity: quantity,
        );
        notifyListeners();
      } else {
        debugPrint('Cannot update quantity: item is locked or not found');
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
    _existingReceiptNo = null;
    _existingItemsCount = 0;
    notifyListeners();
  }

  void setExistingReceiptNo(String? receiptNo) {
    _existingReceiptNo = receiptNo;
    notifyListeners();
  }

  void setExistingItemsCount(int count) {
    _existingItemsCount = count;
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
      // Only count non-existing items (new items that can be edited)
      // Existing items are locked and shouldn't show quantity controls
      final item = _items.firstWhere(
        (item) => item.foodItem.id == foodItem.id && !item.isExisting,
      );
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }

  bool isItemInCart(FoodItem foodItem) {
    // Only check non-existing items (new items that can be edited)
    // Existing items are locked and shouldn't prevent adding new rows
    return _items.any(
      (item) => item.foodItem.id == foodItem.id && !item.isExisting,
    );
  }
}
