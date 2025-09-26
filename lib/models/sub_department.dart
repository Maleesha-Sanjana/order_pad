class SubDepartment {
  final int id;
  final String name;
  final String? description;
  final int departmentId;
  final String? icon;

  const SubDepartment({
    required this.id,
    required this.name,
    this.description,
    required this.departmentId,
    this.icon,
  });

  factory SubDepartment.fromJson(Map<String, dynamic> json) {
    return SubDepartment(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      departmentId: json['departmentId'] as int,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'departmentId': departmentId,
    'icon': icon,
  };
}
