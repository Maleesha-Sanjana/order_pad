class Department {
  final String departmentCode;
  final String? departmentName;
  final int? standardEAN;
  final bool? update;
  final DateTime? createdDate;
  final String? createdUser;
  final DateTime? editedDate;
  final String? editedUser;

  const Department({
    required this.departmentCode,
    this.departmentName,
    this.standardEAN,
    this.update,
    this.createdDate,
    this.createdUser,
    this.editedDate,
    this.editedUser,
  });

  // Helper getters for compatibility
  String get id => departmentCode;
  String get name => departmentName ?? 'Unknown Department';
  String get icon {
    // Map department codes to appropriate emojis
    switch (departmentCode) {
      case '01': return '🍳'; // BREAKFAST
      case '02': return '🍽️'; // MAIN COURSES
      case '03': return '🥪'; // SANDWICH BOARD
      case '04': return '🥟'; // STARTERS & BITES
      case '05': return '👶'; // KIDS MEALS
      case '06': return '🥗'; // SALADS
      case '07': return '🍲'; // SOUPS
      case '08': return '🍰'; // DESSERTS
      case '09': return '🥤'; // BEVERAGES
      case '10': return '🔧'; // OTHER SERVICES
      case '11': return '🏺'; // POTTERY SALE
      default: return '🍽️'; // Default restaurant icon
    }
  }
  int get sortOrder => standardEAN ?? 0;

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      departmentCode: json['DepartmentCode']?.toString() ?? '',
      departmentName: json['DepartmentName']?.toString(),
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
    'DepartmentCode': departmentCode,
    'DepartmentName': departmentName,
    'StandardEAN': standardEAN,
    'Update': update,
    'Created_Date': createdDate?.toIso8601String(),
    'Created_User': createdUser,
    'Edited_Date': editedDate?.toIso8601String(),
    'Edited_User': editedUser,
  };
}
