import 'package:flutter/foundation.dart';
import '../models/department.dart';
import '../models/sub_department.dart';
import '../models/food_item.dart';

class MenuProvider extends ChangeNotifier {
  List<Department> _departments = [];
  List<SubDepartment> _subDepartments = [];
  List<FoodItem> _foodItems = [];
  bool _loading = false;
  String _searchQuery = '';
  int? _selectedDepartmentId;
  int? _selectedSubDepartmentId;

  List<Department> get departments => _departments;
  List<SubDepartment> get subDepartments => _subDepartments;
  List<FoodItem> get foodItems => _foodItems;
  bool get loading => _loading;
  String get searchQuery => _searchQuery;
  int? get selectedDepartmentId => _selectedDepartmentId;
  int? get selectedSubDepartmentId => _selectedSubDepartmentId;

  MenuProvider();

  Future<void> loadMenuData() async {
    _loading = true;
    notifyListeners();

    try {
      // Data is now loaded through DatabaseDataProvider
      // This method is kept for compatibility but data loading
      // is handled by DatabaseDataProvider
      print('Menu data loading is now handled by DatabaseDataProvider');
    } catch (e) {
      print('Error loading menu data: $e');
      _departments = [];
      _subDepartments = [];
      _foodItems = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectDepartment(int? departmentId) {
    _selectedDepartmentId = departmentId;
    _selectedSubDepartmentId = null; // Reset sub-department selection
    notifyListeners();
  }

  void selectSubDepartment(int? subDepartmentId) {
    _selectedSubDepartmentId = subDepartmentId;
    notifyListeners();
  }

  void clearSelection() {
    _selectedDepartmentId = null;
    _selectedSubDepartmentId = null;
    _searchQuery = '';
    notifyListeners();
  }

  // Get sub-departments for selected department
  List<SubDepartment> getSubDepartmentsForSelected() {
    if (_selectedDepartmentId == null) return [];
    return _subDepartments
        .where((sub) => sub.departmentId == _selectedDepartmentId)
        .toList();
  }

  // Get food items based on current selection and search
  List<FoodItem> getFilteredFoodItems() {
    List<FoodItem> filtered = _foodItems;

    // Filter by department
    if (_selectedDepartmentId != null) {
      filtered = filtered
          .where((item) => item.categoryId == _selectedDepartmentId.toString())
          .toList();
    }

    // Filter by sub-department
    if (_selectedSubDepartmentId != null) {
      filtered = filtered
          .where(
            (item) => item.subCategoryId == _selectedSubDepartmentId.toString(),
          )
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        return item.name.toLowerCase().contains(query) ||
            (item.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  // Get all food items (for search across all departments)
  List<FoodItem> getAllFoodItems() {
    if (_searchQuery.isEmpty) return _foodItems;

    final query = _searchQuery.toLowerCase();
    return _foodItems.where((item) {
      return item.name.toLowerCase().contains(query) ||
          (item.description?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  // Get department name by ID
  String getDepartmentName(int departmentId) {
    try {
      return _departments.firstWhere((dept) => dept.id == departmentId).name;
    } catch (e) {
      return 'Unknown Department';
    }
  }

  // Get sub-department name by ID
  String getSubDepartmentName(int subDepartmentId) {
    try {
      return _subDepartments
          .firstWhere((sub) => sub.id == subDepartmentId)
          .name;
    } catch (e) {
      return 'Unknown Sub-Department';
    }
  }
}
