import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_item.dart';
import '../models/department.dart';
import '../models/sub_department.dart';
import '../models/salesman.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

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
