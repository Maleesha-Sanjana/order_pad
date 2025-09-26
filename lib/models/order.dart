import 'cart_item.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final DateTime createdAt;
  final String? customerName;
  final String? tableNumber;
  final String? seatNumber;
  final String status;

  const Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.createdAt,
    this.customerName,
    this.tableNumber,
    this.seatNumber,
    this.status = 'pending',
  });

  factory Order.create({
    required List<CartItem> items,
    String? customerName,
    String? tableNumber,
    String? seatNumber,
  }) {
    final subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    const taxRate = 0.08; // 8% tax
    final tax = subtotal * taxRate;
    final total = subtotal + tax;

    return Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: items,
      subtotal: subtotal,
      tax: tax,
      total: total,
      createdAt: DateTime.now(),
      customerName: customerName,
      tableNumber: tableNumber,
      seatNumber: seatNumber,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'items': items.map((item) => item.toJson()).toList(),
    'subtotal': subtotal,
    'tax': tax,
    'total': total,
    'createdAt': createdAt.toIso8601String(),
    'customerName': customerName,
    'tableNumber': tableNumber,
    'seatNumber': seatNumber,
    'status': status,
  };

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      customerName: json['customerName'] as String?,
      tableNumber: json['tableNumber'] as String?,
      seatNumber: json['seatNumber'] as String?,
      status: json['status'] as String,
    );
  }
}
