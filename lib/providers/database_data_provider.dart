import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/food_item.dart';
import '../models/department.dart';
import '../models/sub_department.dart';
import '../models/salesman.dart';
import '../models/order.dart';

class DatabaseDataProvider extends ChangeNotifier {
  // Data storage
  List<FoodItem> _menuItems = [];
  List<Department> _departments = [];
  List<SubDepartment> _subDepartments = [];
  List<Salesman> _users = [];
  List<Order> _orders = [];

  // Loading states
  bool _isLoadingMenuItems = false;
  bool _isLoadingDepartments = false;
  bool _isLoadingUsers = false;
  bool _isLoadingOrders = false;

  // Error states
  String? _errorMessage;

  // Getters
  List<FoodItem> get menuItems => _menuItems;
  List<Department> get departments => _departments;
  List<SubDepartment> get subDepartments => _subDepartments;
  List<Salesman> get users => _users;
  List<Order> get orders => _orders;

  bool get isLoadingMenuItems => _isLoadingMenuItems;
  bool get isLoadingDepartments => _isLoadingDepartments;
  bool get isLoadingUsers => _isLoadingUsers;
  bool get isLoadingOrders => _isLoadingOrders;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  /// Load all menu items from database
  Future<void> loadMenuItems() async {
    _isLoadingMenuItems = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _menuItems = await ApiService.getProducts();
      print('✅ Loaded ${_menuItems.length} menu items from database');
    } catch (e) {
      _errorMessage = 'Failed to load menu items: $e';
      print('❌ Error loading menu items: $e');
    }

    _isLoadingMenuItems = false;
    notifyListeners();
  }

  /// Load all departments from database
  Future<void> loadDepartments() async {
    _isLoadingDepartments = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔄 Loading departments from API...');
      _departments = await ApiService.getDepartments();
      print('✅ Loaded ${_departments.length} departments from database');
      for (var dept in _departments) {
        print('  - ${dept.name} (${dept.departmentCode})');
      }
    } catch (e) {
      _errorMessage = 'Failed to load departments: $e';
      print('❌ Error loading departments: $e');
    }

    _isLoadingDepartments = false;
    notifyListeners();
  }

  /// Load sub-departments for a specific department
  Future<void> loadSubDepartments(String departmentId) async {
    try {
      _subDepartments = await ApiService.getSubDepartments(departmentId);
      print(
        '✅ Loaded ${_subDepartments.length} sub-departments for department $departmentId',
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load sub-departments: $e';
      print('❌ Error loading sub-departments: $e');
      notifyListeners();
    }
  }

  /// Load products for a specific sub-department
  Future<void> loadProductsBySubDepartment(String subDepartmentCode) async {
    _isLoadingMenuItems = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔄 Loading products for sub-department: $subDepartmentCode');
      _menuItems = await ApiService.getProductsBySubDepartment(subDepartmentCode);
      print('✅ Loaded ${_menuItems.length} products for sub-department $subDepartmentCode');
      for (var item in _menuItems) {
        print('  - ${item.name} (Rs. ${item.price})');
      }
    } catch (e) {
      _errorMessage = 'Failed to load products: $e';
      print('❌ Error loading products for sub-department: $e');
    }

    _isLoadingMenuItems = false;
    notifyListeners();
  }

  /// Load all users from database
  Future<void> loadUsers() async {
    _isLoadingUsers = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await ApiService.getSalesmen();
      print('✅ Loaded ${_users.length} users from database');
    } catch (e) {
      _errorMessage = 'Failed to load users: $e';
      print('❌ Error loading users: $e');
    }

    _isLoadingUsers = false;
    notifyListeners();
  }

  /// Load all orders from database
  Future<void> loadOrders() async {
    _isLoadingOrders = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Orders not implemented in API yet
      _orders = [];
      print('✅ Loaded ${_orders.length} orders from database');
    } catch (e) {
      _errorMessage = 'Failed to load orders: $e';
      print('❌ Error loading orders: $e');
    }

    _isLoadingOrders = false;
    notifyListeners();
  }

  /// Load orders by status
  Future<void> loadOrdersByStatus(String status) async {
    _isLoadingOrders = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Orders not implemented in API yet
      _orders = [];
      print(
        '✅ Loaded ${_orders.length} orders with status $status from database',
      );
    } catch (e) {
      _errorMessage = 'Failed to load orders: $e';
      print('❌ Error loading orders: $e');
    }

    _isLoadingOrders = false;
    notifyListeners();
  }

  /// Load all data from database
  Future<void> loadAllData() async {
    print('🔄 Loading all data from database...');

    // Load all data in parallel
    await Future.wait([
      loadMenuItems(),
      loadDepartments(),
      loadUsers(),
      loadOrders(),
    ]);

    print('✅ All data loaded from database');
    print('📊 Final counts - Departments: ${_departments.length}, Menu Items: ${_menuItems.length}');
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refreshAllData() async {
    print('🔄 Refreshing all data from database...');
    await loadAllData();
  }

  /// Get menu items by department
  List<FoodItem> getMenuItemsByDepartment(String departmentId) {
    return _menuItems.where((item) => item.categoryId == departmentId).toList();
  }

  /// Get menu items by sub-department
  List<FoodItem> getMenuItemsBySubDepartment(String subDepartmentId) {
    return _menuItems
        .where((item) => item.subCategoryId == subDepartmentId)
        .toList();
  }

  /// Get orders by table number
  List<Order> getOrdersByTable(String tableNumber) {
    return _orders.where((order) => order.tableNumber == tableNumber).toList();
  }

  /// Get orders by service type
  List<Order> getOrdersByServiceType(String serviceType) {
    return _orders.where((order) => order.serviceType == serviceType).toList();
  }
}
