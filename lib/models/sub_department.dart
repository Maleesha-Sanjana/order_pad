class SubDepartment {
  final String subDepartmentCode;
  final String? subDepartmentName;
  final String? departmentCode;
  final int? standardEAN;
  final bool? update;
  final DateTime? createdDate;
  final String? createdUser;
  final DateTime? editedDate;
  final String? editedUser;

  const SubDepartment({
    required this.subDepartmentCode,
    this.subDepartmentName,
    this.departmentCode,
    this.standardEAN,
    this.update,
    this.createdDate,
    this.createdUser,
    this.editedDate,
    this.editedUser,
  });

  // Helper getters for compatibility
  String get id => subDepartmentCode;
  String get name => subDepartmentName ?? 'Unknown Sub-Department';
  String get departmentId => departmentCode ?? '';

  factory SubDepartment.fromJson(Map<String, dynamic> json) {
    return SubDepartment(
      subDepartmentCode: json['SubDepartmentCode']?.toString() ?? '',
      subDepartmentName: json['SubDepartmentName']?.toString(),
      departmentCode: json['DepartmentCode']?.toString(),
      standardEAN:
          json['StandardEAN'] != null &&
              json['StandardEAN'].toString() != 'NULL'
          ? int.tryParse(json['StandardEAN'].toString())
          : null,
      update: json['Update']?.toString() == '1',
      createdDate:
          json['Created_Date'] != null &&
              json['Created_Date'].toString() != 'NULL'
          ? DateTime.tryParse(json['Created_Date'].toString())
          : null,
      createdUser: json['Created_User']?.toString(),
      editedDate:
          json['Edited_Date'] != null &&
              json['Edited_Date'].toString() != 'NULL'
          ? DateTime.tryParse(json['Edited_Date'].toString())
          : null,
      editedUser: json['Edited_User']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'SubDepartmentCode': subDepartmentCode,
    'SubDepartmentName': subDepartmentName,
    'DepartmentCode': departmentCode,
    'StandardEAN': standardEAN,
    'Update': update,
    'Created_Date': createdDate?.toIso8601String(),
    'Created_User': createdUser,
    'Edited_Date': editedDate?.toIso8601String(),
    'Edited_User': editedUser,
  };
}
