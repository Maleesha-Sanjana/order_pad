import 'food_item.dart';

class Order {
  final String id;
  final String tableNumber;
  final String seatNumber;
  final String serviceType;
  final double totalAmount;
  final String status;
  final String? remarks;
  final String createdBy;
  final DateTime createdAt;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.tableNumber,
    required this.seatNumber,
    required this.serviceType,
    required this.totalAmount,
    required this.status,
    this.remarks,
    required this.createdBy,
    required this.createdAt,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      tableNumber: json['tableNumber']?.toString() ?? '',
      seatNumber: json['seatNumber']?.toString() ?? '',
      serviceType: json['serviceType']?.toString() ?? '',
      totalAmount:
          double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
      remarks: json['remarks']?.toString(),
      createdBy: json['createdBy']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tableNumber': tableNumber,
    'seatNumber': seatNumber,
    'serviceType': serviceType,
    'totalAmount': totalAmount,
    'status': status,
    'remarks': remarks,
    'createdBy': createdBy,
    'createdAt': createdAt.toIso8601String(),
    'items': items.map((item) => item.toJson()).toList(),
  };

  Order copyWith({
    String? id,
    String? tableNumber,
    String? seatNumber,
    String? serviceType,
    double? totalAmount,
    String? status,
    String? remarks,
    String? createdBy,
    DateTime? createdAt,
    List<OrderItem>? items,
  }) {
    return Order(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      seatNumber: seatNumber ?? this.seatNumber,
      serviceType: serviceType ?? this.serviceType,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String menuItemId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? specialInstructions;
  final FoodItem? menuItem;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.specialInstructions,
    this.menuItem,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      menuItemId: json['menuItemId']?.toString() ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      unitPrice: double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0.0,
      totalPrice: double.tryParse(json['totalPrice']?.toString() ?? '0') ?? 0.0,
      specialInstructions: json['specialInstructions']?.toString(),
      menuItem: json['menuItem'] != null
          ? FoodItem.fromJson(json['menuItem'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderId': orderId,
    'menuItemId': menuItemId,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'totalPrice': totalPrice,
    'specialInstructions': specialInstructions,
    'menuItem': menuItem?.toJson(),
  };

  OrderItem copyWith({
    String? id,
    String? orderId,
    String? menuItemId,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? specialInstructions,
    FoodItem? menuItem,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      menuItemId: menuItemId ?? this.menuItemId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      menuItem: menuItem ?? this.menuItem,
    );
  }
}


