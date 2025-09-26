import 'food_item.dart';

class CartItem {
  final FoodItem foodItem;
  final int quantity;
  final String? specialInstructions;

  const CartItem({
    required this.foodItem,
    required this.quantity,
    this.specialInstructions,
  });

  double get totalPrice => foodItem.price * quantity;

  CartItem copyWith({
    FoodItem? foodItem,
    int? quantity,
    String? specialInstructions,
  }) {
    return CartItem(
      foodItem: foodItem ?? this.foodItem,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }

  Map<String, dynamic> toJson() => {
    'foodItem': foodItem.toJson(),
    'quantity': quantity,
    'specialInstructions': specialInstructions,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      foodItem: FoodItem.fromJson(json['foodItem']),
      quantity: json['quantity'] as int,
      specialInstructions: json['specialInstructions'] as String?,
    );
  }
}
