import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/realtime_sync_service.dart';
import '../models/food_item.dart';
import '../models/department.dart';
import '../models/sub_department.dart';
import '../models/salesman.dart';
import '../models/order.dart';
import '../models/suspend_order.dart';

class DatabaseDataProvider extends ChangeNotifier {
  // Data storage
  List<FoodItem> _menuItems = [];
  List<Department> _departments = [];
  List<SubDepartment> _subDepartments = [];
  List<Salesman> _users = [];
  List<Order> _orders = [];
  List<SuspendOrder> _suspendOrders = [];

  // Loading states
  bool _isLoadingMenuItems = false;
  bool _isLoadingDepartments = false;
  bool _isLoadingUsers = false;
  bool _isLoadingOrders = false;
  bool _isLoadingSuspendOrders = false;

  // Error states
  String? _errorMessage;

  // Real-time sync
  final RealtimeSyncService _realtimeSync = RealtimeSyncService();
  bool _isRealtimeEnabled = true;
  StreamSubscription? _connectionStatusSubscription;
  StreamSubscription? _dataChangesSubscription;
  Timer? _autoRefreshTimer;

  // Getters
  List<FoodItem> get menuItems => _menuItems;
  List<Department> get departments => _departments;
  List<SubDepartment> get subDepartments => _subDepartments;
  List<Salesman> get users => _users;
  List<Order> get orders => _orders;
  List<SuspendOrder> get suspendOrders => _suspendOrders;

  bool get isLoadingMenuItems => _isLoadingMenuItems;
  bool get isLoadingDepartments => _isLoadingDepartments;
  bool get isLoadingUsers => _isLoadingUsers;
  bool get isLoadingOrders => _isLoadingOrders;
  bool get isLoadingSuspendOrders => _isLoadingSuspendOrders;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  // Real-time sync getters
  bool get isRealtimeEnabled => _isRealtimeEnabled;
  bool get isConnected => _realtimeSync.isConnected;
  bool get isPolling => _realtimeSync.isPolling;
  bool get isWebSocketConnected => _realtimeSync.isWebSocketConnected;

  /// Initialize the provider with real-time sync
  Future<void> initialize() async {
    print('🔄 Initializing DatabaseDataProvider with real-time sync...');
    
    try {
      // Initialize real-time sync service
      await _realtimeSync.initialize();
      
      // Register update callbacks
      _registerRealtimeCallbacks();
      
      // Listen to connection status changes
      _connectionStatusSubscription = _realtimeSync.connectionStatus.listen((isConnected) {
        print('🔗 Connection status changed: $isConnected');
        notifyListeners();
      });
      
      // Listen to data changes
      _dataChangesSubscription = _realtimeSync.dataChanges.listen((change) {
        print('📊 Data change received: ${change['type']}');
        _handleDataChange(change);
      });
      
      // Enable sync for all data types
      _realtimeSync.enableSyncFor([
        'departments',
        'products',
        'suspend_orders',
        'orders',
        'users',
      ]);
      
      // Start auto-refresh timer (every 5 minutes as backup)
      _autoRefreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
        if (_isRealtimeEnabled) {
          refreshAllData();
        }
      });
      
      print('✅ DatabaseDataProvider initialized with real-time sync');
    } catch (e) {
      print('❌ Failed to initialize real-time sync: $e');
      _errorMessage = 'Real-time sync initialization failed: $e';
      notifyListeners();
    }
  }

  /// Register callbacks for real-time updates
  void _registerRealtimeCallbacks() {
    _realtimeSync.registerUpdateCallback('departments', () {
      print('🔄 Real-time update: departments');
      loadDepartments();
    });
    
    _realtimeSync.registerUpdateCallback('products', () {
      print('🔄 Real-time update: products');
      loadMenuItems();
    });
    
    _realtimeSync.registerUpdateCallback('suspend_orders', () {
      print('🔄 Real-time update: suspend_orders');
      loadSuspendOrders();
    });
    
    _realtimeSync.registerUpdateCallback('orders', () {
      print('🔄 Real-time update: orders');
      loadOrders();
    });
    
    _realtimeSync.registerUpdateCallback('users', () {
      print('🔄 Real-time update: users');
      loadUsers();
    });
  }

  /// Handle real-time data changes
  void _handleDataChange(Map<String, dynamic> change) {
    final dataType = change['type'] as String;
    final timestamp = change['timestamp'] as String;
    
    print('📊 Processing real-time change: $dataType at $timestamp');
    
    // Update UI based on change type
    switch (dataType) {
      case 'departments':
        loadDepartments();
        break;
      case 'products':
        loadMenuItems();
        break;
      case 'suspend_orders':
        loadSuspendOrders();
        break;
      case 'orders':
        loadOrders();
        break;
      case 'users':
        loadUsers();
        break;
      default:
        print('⚠️ Unknown data change type: $dataType');
    }
  }

  /// Enable or disable real-time synchronization
  void setRealtimeEnabled(bool enabled) {
    _isRealtimeEnabled = enabled;
    
    if (enabled) {
      _realtimeSync.enableSyncFor([
        'departments',
        'products',
        'suspend_orders',
        'orders',
        'users',
      ]);
      print('✅ Real-time sync enabled');
    } else {
      _realtimeSync.disableSyncFor([
        'departments',
        'products',
        'suspend_orders',
        'orders',
        'users',
      ]);
      print('❌ Real-time sync disabled');
    }
    
    notifyListeners();
  }

  /// Force refresh all data
  Future<void> forceRefresh() async {
    print('🔄 Force refreshing all data...');
    await _realtimeSync.forceRefresh();
  }

  /// Get real-time sync status
  Map<String, dynamic> getRealtimeStatus() {
    return {
      'isEnabled': _isRealtimeEnabled,
      'isConnected': isConnected,
      'isPolling': isPolling,
      'isWebSocketConnected': isWebSocketConnected,
      'syncStatus': _realtimeSync.getSyncStatus(),
    };
  }

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

  /// Load all suspend orders from database
  Future<void> loadSuspendOrders() async {
    _isLoadingSuspendOrders = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _suspendOrders = await ApiService.getSuspendOrders();
      print('✅ Loaded ${_suspendOrders.length} suspend orders from database');
    } catch (e) {
      _errorMessage = 'Failed to load suspend orders: $e';
      print('❌ Error loading suspend orders: $e');
    }

    _isLoadingSuspendOrders = false;
    notifyListeners();
  }

  /// Load suspend orders by table
  Future<void> loadSuspendOrdersByTable(String tableNumber) async {
    _isLoadingSuspendOrders = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _suspendOrders = await ApiService.getSuspendOrdersByTable(tableNumber);
      print('✅ Loaded ${_suspendOrders.length} suspend orders for table $tableNumber');
    } catch (e) {
      _errorMessage = 'Failed to load suspend orders: $e';
      print('❌ Error loading suspend orders for table $tableNumber: $e');
    }

    _isLoadingSuspendOrders = false;
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
      loadSuspendOrders(),
    ]);

    print('✅ All data loaded from database');
    print('📊 Final counts - Departments: ${_departments.length}, Menu Items: ${_menuItems.length}, Suspend Orders: ${_suspendOrders.length}');
  }

  /// Dispose and cleanup resources
  @override
  void dispose() {
    print('🔄 Disposing DatabaseDataProvider...');
    
    // Cancel subscriptions
    _connectionStatusSubscription?.cancel();
    _dataChangesSubscription?.cancel();
    
    // Cancel auto-refresh timer
    _autoRefreshTimer?.cancel();
    
    // Disconnect real-time sync
    _realtimeSync.disconnect();
    
    super.dispose();
    print('✅ DatabaseDataProvider disposed');
  }

  /// Add item to cart (create suspend order)
  Future<void> addToCart(SuspendOrder order) async {
    try {
      print('🔄 DatabaseDataProvider: Adding item to cart: ${order.productDescription}');
      print('📦 DatabaseDataProvider: Order details:');
      print('   - ProductCode: ${order.productCode}');
      print('   - Table: ${order.table}');
      print('   - SalesMan: ${order.salesMan}');
      print('   - Amount: ${order.amount}');
      
      final result = await ApiService.createSuspendOrder(order);
      print('📊 DatabaseDataProvider: API result: $result');
      print('📊 DatabaseDataProvider: API result type: ${result.runtimeType}');
      print('📊 DatabaseDataProvider: API success field: ${result['success']}');
      
      if (result['success'] == true) {
        // Don't reload suspend orders to avoid hanging - just mark as successful
        print('✅ DatabaseDataProvider: Added item to cart successfully');
      } else {
        print('❌ DatabaseDataProvider: API returned success: false');
        _errorMessage = 'Failed to add item to cart: API returned success false';
        notifyListeners();
        throw Exception('API returned success: false');
      }
    } catch (e) {
      _errorMessage = 'Failed to add item to cart: $e';
      print('❌ DatabaseDataProvider: Error adding item to cart: $e');
      notifyListeners();
      throw e; // Re-throw to let the caller handle it
    }
  }

  /// Update cart item (update suspend order)
  Future<void> updateCartItem(int id, SuspendOrder order) async {
    try {
      final result = await ApiService.updateSuspendOrder(id, order);
      if (result['success'] == true) {
        // Reload suspend orders to get updated list
        await loadSuspendOrders();
        print('✅ Updated cart item successfully');
      }
    } catch (e) {
      _errorMessage = 'Failed to update cart item: $e';
      print('❌ Error updating cart item: $e');
      notifyListeners();
    }
  }

  /// Remove item from cart (delete suspend order)
  Future<void> removeFromCart(int id) async {
    try {
      final result = await ApiService.deleteSuspendOrder(id);
      if (result['success'] == true) {
        // Reload suspend orders to get updated list
        await loadSuspendOrders();
        print('✅ Removed item from cart successfully');
      }
    } catch (e) {
      _errorMessage = 'Failed to remove item from cart: $e';
      print('❌ Error removing item from cart: $e');
      notifyListeners();
    }
  }

  /// Confirm order (finalize suspend orders)
  Future<Map<String, dynamic>?> confirmOrder(String tableNumber, {
    String? receiptNo,
    String? salesMan,
  }) async {
    try {
      print('🔄 Confirming order for table: $tableNumber');
      print('📋 Receipt: $receiptNo, Salesman: $salesMan');
      
      // Add timeout to prevent hanging
      final result = await ApiService.confirmOrder(tableNumber, 
        receiptNo: receiptNo, 
        salesMan: salesMan
      ).timeout(Duration(seconds: 10));
      
      print('📊 Confirm order API result: $result');
      
      if (result['success'] == true) {
        print('✅ Order confirmed successfully');
        // Don't reload suspend orders here to avoid hanging
        // The order confirmation is complete
        return result;
      } else {
        print('❌ Confirm order API returned success: false');
        _errorMessage = 'Failed to confirm order: API returned success false';
        notifyListeners();
        throw Exception('API returned success: false');
      }
    } on TimeoutException {
      _errorMessage = 'Order confirmation timed out. Please check if the order was processed.';
      print('❌ Order confirmation timed out');
      notifyListeners();
      throw Exception('Order confirmation timed out');
    } catch (e) {
      _errorMessage = 'Failed to confirm order: $e';
      print('❌ Error confirming order: $e');
      notifyListeners();
      throw e; // Re-throw to let the caller handle it
    }
  }

  /// Clear cart (cancel order)
  Future<void> clearCart(String tableNumber) async {
    try {
      final result = await ApiService.clearSuspendOrders(tableNumber);
      if (result['success'] == true) {
        // Reload suspend orders to get updated list
        await loadSuspendOrders();
        print('✅ Cart cleared successfully');
      }
    } catch (e) {
      _errorMessage = 'Failed to clear cart: $e';
      print('❌ Error clearing cart: $e');
      notifyListeners();
    }
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

  /// Get suspend orders by table
  List<SuspendOrder> getSuspendOrdersByTable(String tableNumber) {
    return _suspendOrders.where((order) => order.table == tableNumber).toList();
  }

  /// Get cart total for a specific table
  double getCartTotal(String tableNumber) {
    final tableOrders = getSuspendOrdersByTable(tableNumber);
    return tableOrders.fold(0.0, (sum, order) => sum + order.amount);
  }

  /// Get cart item count for a specific table
  int getCartItemCount(String tableNumber) {
    return getSuspendOrdersByTable(tableNumber).length;
  }

  /// Check if table has pending orders
  bool hasPendingOrders(String tableNumber) {
    return getSuspendOrdersByTable(tableNumber).isNotEmpty;
  }

  /// Get all tables with pending orders
  List<String> getTablesWithPendingOrders() {
    final tables = _suspendOrders.map((order) => order.table).toSet().toList();
    return tables.where((table) => hasPendingOrders(table)).toList();
  }
}
