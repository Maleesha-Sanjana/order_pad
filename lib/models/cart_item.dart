import 'food_item.dart';

class CartItem {
  final FoodItem foodItem;
  final int quantity;
  final String? specialInstructions;
  final bool isExisting; // True if this is a previously confirmed order (read-only)

  const CartItem({
    required this.foodItem,
    required this.quantity,
    this.specialInstructions,
    this.isExisting = false, // Default is false (new item)
  });

  double get totalPrice => foodItem.price * quantity;

  CartItem copyWith({
    FoodItem? foodItem,
    int? quantity,
    String? specialInstructions,
    bool? isExisting,
  }) {
    return CartItem(
      foodItem: foodItem ?? this.foodItem,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      isExisting: isExisting ?? this.isExisting,
    );
  }

  Map<String, dynamic> toJson() => {
    'foodItem': foodItem.toJson(),
    'quantity': quantity,
    'specialInstructions': specialInstructions,
    'isExisting': isExisting,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      foodItem: FoodItem.fromJson(json['foodItem']),
      quantity: json['quantity'] as int,
      specialInstructions: json['specialInstructions'] as String?,
      isExisting: json['isExisting'] as bool? ?? false,
    );
  }
}
