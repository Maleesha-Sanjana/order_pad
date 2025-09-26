class Department {
  final int id;
  final String name;
  final String? description;
  final String? icon;

  const Department({
    required this.id,
    required this.name,
    this.description,
    this.icon,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
  };
}
