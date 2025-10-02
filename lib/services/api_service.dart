// ignore_for_file: unused_element

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_item.dart';
import '../models/department.dart';
import '../models/sub_department.dart';
import '../models/salesman.dart';
import '../models/suspend_order.dart';

class ApiService {
  static const String baseUrl = 'http://172.20.10.3:3000/api';

  // Helper method to handle HTTP responses
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  // ==================== DEPARTMENTS ====================

  static Future<List<Department>> getDepartments() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/departments'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((json) => Department.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load departments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching departments: $e');
      return [];
    }
  }

  // ==================== SUB-DEPARTMENTS ====================

  static Future<List<SubDepartment>> getSubDepartments(
    String departmentCode,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subdepartments/$departmentCode'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((json) => SubDepartment.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load sub-departments: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching sub-departments: $e');
      return [];
    }
  }

  // ==================== PRODUCTS ====================

  static Future<List<FoodItem>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((json) => FoodItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  static Future<List<FoodItem>> getProductsByDepartment(
    String departmentCode,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/department/$departmentCode'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((json) => FoodItem.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load products by department: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching products by department: $e');
      return [];
    }
  }

  static Future<List<FoodItem>> getProductsBySubDepartment(
    String subDepartmentCode,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/subdepartment/$subDepartmentCode'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((json) => FoodItem.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load products by sub-department: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching products by sub-department: $e');
      return [];
    }
  }

  static Future<List<FoodItem>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/search?q=${Uri.encodeComponent(query)}'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((json) => FoodItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  // ==================== AUTHENTICATION ====================

  static Future<Map<String, dynamic>> authenticateSalesman(
    String salesmanCode,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'salesmanCode': salesmanCode, 'password': password}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Authentication failed');
      }
    } catch (e) {
      print('Error authenticating salesman: $e');
      rethrow;
    }
  }

  // Password-only authentication

  static Future<Map<String, dynamic>> authenticateWithPassword(
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'password': password}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Authentication failed');
      }
    } catch (e) {
      print('Error authenticating with password: $e');
      rethrow;
    }
  }

  static Future<List<Salesman>> getSalesmen() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/salesmen'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((json) => Salesman.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load salesmen: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching salesmen: $e');
      return [];
    }
  }

  // ==================== SUSPEND ORDERS ====================

  static Future<List<SuspendOrder>> getSuspendOrders() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/suspend-orders'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((json) => SuspendOrder.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load suspend orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching suspend orders: $e');
      return [];
    }
  }

  static Future<List<SuspendOrder>> getSuspendOrdersByTable(String tableNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/suspend-orders/table/$tableNumber'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((json) => SuspendOrder.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load suspend orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching suspend orders by table: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> createSuspendOrder(SuspendOrder order) async {
    try {
      print('🔄 API: Creating suspend order for ${order.productDescription}');
      print('📋 API: Table: ${order.table}, Amount: ${order.amount}');
      
      final orderJson = order.toJson();
      print('📦 API: Order JSON: $orderJson');
      final requestBody = json.encode(orderJson);
      print('📦 API: Request body: $requestBody');
      
      final response = await http.post(
        Uri.parse('$baseUrl/suspend-orders'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      print('📊 API: Response status: ${response.statusCode}');
      print('📊 API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = json.decode(response.body);
        print('✅ API: Suspend order created successfully');
        return result;
      } else {
        print('❌ API: Failed to create suspend order: ${response.statusCode}');
        throw Exception('Failed to create suspend order: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ API: Error creating suspend order: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateSuspendOrder(int id, SuspendOrder order) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/suspend-orders/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(order.toJson()),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update suspend order: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating suspend order: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> deleteSuspendOrder(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/suspend-orders/$id'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete suspend order: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting suspend order: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> confirmOrder(String tableNumber, {
    String? receiptNo,
    String? salesMan,
  }) async {
    try {
      print('🔄 API: Confirming order for table: $tableNumber');
      print('📋 API: Receipt: $receiptNo, Salesman: $salesMan');
      
      final response = await http.post(
        Uri.parse('$baseUrl/orders/confirm/$tableNumber'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'receiptNo': receiptNo,
          'salesMan': salesMan,
        }),
      );

      print('📊 API: Confirm order response status: ${response.statusCode}');
      print('📊 API: Confirm order response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('✅ API: Order confirmed successfully');
        print('📊 API: Raw response body: ${response.body}');
        print('📊 API: Parsed result: $result');
        print('📊 API: Result success field: ${result['success']}');
        return result;
      } else {
        print('❌ API: Failed to confirm order: ${response.statusCode}');
        print('📊 API: Error response body: ${response.body}');
        throw Exception('Failed to confirm order: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ API: Error confirming order: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> clearSuspendOrders(String tableNumber) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/suspend-orders/table/$tableNumber'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to clear suspend orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error clearing suspend orders: $e');
      rethrow;
    }
  }

  // ==================== HEALTH CHECK ====================

  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }
}
