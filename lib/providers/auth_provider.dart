import 'package:flutter/foundation.dart';
import '../models/salesman.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  // Authentication state
  Salesman? _currentSalesman;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  // Getters
  Salesman? get currentSalesman => _currentSalesman;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasError => _errorMessage != null;

  // Get salesman display info
  String get salesmanName => _currentSalesman?.displayName ?? 'Unknown';
  String get salesmanCode => _currentSalesman?.salesmanCode ?? '';
  String get salesmanTitle => _currentSalesman?.title ?? 'Salesman';

  /// Login with salesman code and password
  Future<bool> login(String salesmanCode, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔐 Attempting login for salesman: $salesmanCode');

      // Authenticate with API
      final response = await ApiService.authenticateSalesman(
        salesmanCode,
        password,
      );

      if (response['success'] == true) {
        _currentSalesman = Salesman.fromJson(response['salesman']);
        _isAuthenticated = true;
        _errorMessage = null;

        print('✅ Login successful: ${_currentSalesman!.displayName}');
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            response['message'] ?? 'Invalid salesman code or password';
        _isAuthenticated = false;
        print('❌ Login failed: ${_errorMessage}');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      _isAuthenticated = false;
      print('❌ Login error: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login with password only (automatically finds salesman by password)
  Future<bool> loginWithPassword(String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔐 Attempting password-only login');

      // Authenticate with API using password only
      final response = await ApiService.authenticateWithPassword(password);

      if (response['success'] == true) {
        _currentSalesman = Salesman.fromJson(response['salesman']);
        _isAuthenticated = true;
        _errorMessage = null;

        print('✅ Password login successful: ${_currentSalesman!.displayName}');
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Invalid password';
        _isAuthenticated = false;
        print('❌ Password login failed: ${_errorMessage}');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      _isAuthenticated = false;
      print('❌ Password login error: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout current salesman
  void logout() {
    _currentSalesman = null;
    _isAuthenticated = false;
    _errorMessage = null;
    _isLoading = false;

    print('🚪 Logged out successfully');
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Check if salesman code exists in database
  Future<bool> checkSalesmanCodeExists(String salesmanCode) async {
    try {
      final salesmen = await ApiService.getSalesmen();
      return salesmen.any((s) => s.salesmanCode == salesmanCode);
    } catch (e) {
      print('❌ Error checking salesman code: $e');
      return false;
    }
  }

  /// Get all available salesmen (for admin purposes)
  Future<List<Salesman>> getAllSalesmen() async {
    try {
      return await ApiService.getSalesmen();
    } catch (e) {
      print('❌ Error fetching salesmen: $e');
      return [];
    }
  }

  /// Validate salesman code format
  bool isValidSalesmanCode(String code) {
    return code.isNotEmpty && code.length >= 3;
  }

  /// Validate password format
  bool isValidPassword(String password) {
    return password.isNotEmpty && password.length >= 4;
  }

  /// Check if current salesman is active
  bool get isCurrentSalesmanActive {
    return _currentSalesman?.isActive ?? false;
  }

  /// Get salesman permissions/access level
  String get accessLevel {
    if (_currentSalesman == null) return 'None';

    // You can implement permission logic based on salesman type or other fields
    switch (_currentSalesman!.salesmanType?.toLowerCase()) {
      case 'admin':
      case 'manager':
        return 'Admin';
      case 'supervisor':
        return 'Supervisor';
      case 'waiter':
      case 'server':
        return 'Waiter';
      default:
        return 'Standard';
    }
  }

  /// Check if salesman has admin access
  bool get isAdmin {
    return accessLevel == 'Admin';
  }

  /// Check if salesman has supervisor access
  bool get isSupervisor {
    return accessLevel == 'Admin' || accessLevel == 'Supervisor';
  }

  /// Get salesman contact info
  String get contactInfo {
    if (_currentSalesman == null) return '';

    final parts = <String>[];
    if (_currentSalesman!.mobile?.isNotEmpty == true) {
      parts.add('Mobile: ${_currentSalesman!.mobile}');
    }
    if (_currentSalesman!.email?.isNotEmpty == true) {
      parts.add('Email: ${_currentSalesman!.email}');
    }

    return parts.join('\n');
  }

  /// Get salesman address
  String get address {
    if (_currentSalesman == null) return '';

    final parts = <String>[];
    if (_currentSalesman!.address1?.isNotEmpty == true) {
      parts.add(_currentSalesman!.address1!);
    }
    if (_currentSalesman!.address2?.isNotEmpty == true) {
      parts.add(_currentSalesman!.address2!);
    }
    if (_currentSalesman!.address3?.isNotEmpty == true) {
      parts.add(_currentSalesman!.address3!);
    }

    return parts.join(', ');
  }
}
