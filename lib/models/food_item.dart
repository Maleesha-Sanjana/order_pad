class FoodItem {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int sellerId;
  final bool isAvailable;
  final int departmentId;
  final int subDepartmentId;

  const FoodItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.sellerId,
    this.isAvailable = true,
    required this.departmentId,
    required this.subDepartmentId,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      sellerId: json['sellerId'] as int,
      isAvailable: json['isAvailable'] as bool? ?? true,
      departmentId: json['departmentId'] as int,
      subDepartmentId: json['subDepartmentId'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'sellerId': sellerId,
    'isAvailable': isAvailable,
    'departmentId': departmentId,
    'subDepartmentId': subDepartmentId,
  };

  // Helper method to get the price
  double getPrice() {
    return price;
  }
}
