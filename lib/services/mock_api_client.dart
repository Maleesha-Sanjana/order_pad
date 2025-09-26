import '../models/user.dart';
import '../models/food_item.dart';
import '../models/department.dart';
import '../models/sub_department.dart';

class MockApiClient {
  // Mock users database - Only waiters
  static final List<AppUser> _mockUsers = [
    const AppUser(
      id: 1,
      email: 'waitor@gmail.com',
      role: 'waiter',
      name: 'Waiter User',
      phone: '+9478636508',
    ),
  ];

  // Mock passwords (in real app, these would be hashed)
  static final Map<String, String> _mockPasswords = {
    'waitor@gmail.com': 'waitor123',
  };

  // Mock departments - Sri Lankan Cuisine
  static final List<Department> _mockDepartments = [
    const Department(
      id: 1,
      name: 'Rice & Curry',
      description: 'Traditional Sri Lankan rice and curry dishes',
      icon: '🍚',
    ),
    const Department(
      id: 2,
      name: 'Hoppers & String Hoppers',
      description: 'Traditional Sri Lankan hoppers and string hoppers',
      icon: '🥞',
    ),
    const Department(
      id: 3,
      name: 'Kottu & Roti',
      description: 'Popular Sri Lankan street food and roti dishes',
      icon: '🥙',
    ),
    const Department(
      id: 4,
      name: 'Beverages',
      description: 'Traditional Sri Lankan drinks and beverages',
      icon: '🥤',
    ),
    const Department(
      id: 5,
      name: 'Desserts',
      description: 'Traditional Sri Lankan sweets and desserts',
      icon: '🍰',
    ),
  ];

  // Mock sub-departments - Sri Lankan Cuisine
  static final List<SubDepartment> _mockSubDepartments = [
    // Rice & Curry sub-departments
    const SubDepartment(
      id: 1,
      name: 'White Rice & Curry',
      departmentId: 1,
      icon: '🍚',
    ),
    const SubDepartment(
      id: 2,
      name: 'Red Rice & Curry',
      departmentId: 1,
      icon: '🍚',
    ),
    const SubDepartment(
      id: 3,
      name: 'Biriyani & Fried Rice',
      departmentId: 1,
      icon: '🍛',
    ),
    // Hoppers & String Hoppers sub-departments
    const SubDepartment(
      id: 4,
      name: 'Plain Hoppers',
      departmentId: 2,
      icon: '🥞',
    ),
    const SubDepartment(
      id: 5,
      name: 'Egg Hoppers',
      departmentId: 2,
      icon: '🥚',
    ),
    const SubDepartment(
      id: 6,
      name: 'String Hoppers',
      departmentId: 2,
      icon: '🍜',
    ),
    // Kottu & Roti sub-departments
    const SubDepartment(
      id: 7,
      name: 'Chicken Kottu',
      departmentId: 3,
      icon: '🍗',
    ),
    const SubDepartment(
      id: 8,
      name: 'Vegetable Kottu',
      departmentId: 3,
      icon: '🥬',
    ),
    const SubDepartment(
      id: 9,
      name: 'Roti & Paratha',
      departmentId: 3,
      icon: '🥙',
    ),
    // Beverages sub-departments
    const SubDepartment(
      id: 10,
      name: 'Tea & Coffee',
      departmentId: 4,
      icon: '☕',
    ),
    const SubDepartment(
      id: 11,
      name: 'Fresh Juices',
      departmentId: 4,
      icon: '🧊',
    ),
    // Desserts sub-departments
    const SubDepartment(
      id: 12,
      name: 'Traditional Sweets',
      departmentId: 5,
      icon: '🍯',
    ),
    const SubDepartment(
      id: 13,
      name: 'Ice Cream & Falooda',
      departmentId: 5,
      icon: '🍦',
    ),
  ];

  // Mock food items - Sri Lankan Cuisine
  static final List<FoodItem> _mockFoodItems = [
    // White Rice & Curry (Sub-department 1)
    const FoodItem(
      id: 1,
      name: 'White Rice with Chicken Curry',
      description:
          'Traditional white rice served with spicy chicken curry and accompaniments',
      price: 450,
      sellerId: 1,
      isAvailable: true,
      departmentId: 1,
      subDepartmentId: 1,
    ),
    const FoodItem(
      id: 2,
      name: 'White Rice with Fish Curry',
      description:
          'White rice with traditional Sri Lankan fish curry and vegetables',
      price: 480,
      sellerId: 1,
      isAvailable: true,
      departmentId: 1,
      subDepartmentId: 1,
    ),
    const FoodItem(
      id: 3,
      name: 'White Rice with Vegetable Curry',
      description: 'White rice with mixed vegetable curry and dhal',
      price: 380,
      sellerId: 1,
      isAvailable: true,
      departmentId: 1,
      subDepartmentId: 1,
    ),

    // Red Rice & Curry (Sub-department 2)
    const FoodItem(
      id: 4,
      name: 'Red Rice with Chicken Curry',
      description:
          'Nutritious red rice with spicy chicken curry and traditional sides',
      price: 480,
      sellerId: 1,
      isAvailable: true,
      departmentId: 1,
      subDepartmentId: 2,
    ),
    const FoodItem(
      id: 5,
      name: 'Red Rice with Fish Curry',
      description:
          'Red rice with authentic Sri Lankan fish curry and accompaniments',
      price: 520,
      sellerId: 1,
      isAvailable: true,
      departmentId: 1,
      subDepartmentId: 2,
    ),

    // Biriyani & Fried Rice (Sub-department 3)
    const FoodItem(
      id: 6,
      name: 'Chicken Biriyani',
      description:
          'Fragrant basmati rice with spiced chicken and aromatic spices',
      price: 650,
      sellerId: 1,
      isAvailable: true,
      departmentId: 1,
      subDepartmentId: 3,
    ),
    const FoodItem(
      id: 7,
      name: 'Fish Biriyani',
      description: 'Traditional biriyani with spiced fish and basmati rice',
      price: 680,
      sellerId: 1,
      isAvailable: true,
      departmentId: 1,
      subDepartmentId: 3,
    ),
    const FoodItem(
      id: 8,
      name: 'Egg Fried Rice',
      description: 'Fried rice with scrambled eggs and vegetables',
      price: 350,
      sellerId: 1,
      isAvailable: true,
      departmentId: 1,
      subDepartmentId: 3,
    ),

    // Plain Hoppers (Sub-department 4)
    const FoodItem(
      id: 9,
      name: 'Plain Hoppers (3 pieces)',
      description: 'Traditional Sri Lankan hoppers with coconut milk',
      price: 180,
      sellerId: 1,
      isAvailable: true,
      departmentId: 2,
      subDepartmentId: 4,
    ),
    const FoodItem(
      id: 10,
      name: 'Plain Hoppers (6 pieces)',
      description: 'Traditional Sri Lankan hoppers with coconut milk',
      price: 350,
      sellerId: 1,
      isAvailable: true,
      departmentId: 2,
      subDepartmentId: 4,
    ),

    // Egg Hoppers (Sub-department 5)
    const FoodItem(
      id: 11,
      name: 'Egg Hoppers (3 pieces)',
      description: 'Hoppers with a fried egg in the center',
      price: 250,
      sellerId: 1,
      isAvailable: true,
      departmentId: 2,
      subDepartmentId: 5,
    ),
    const FoodItem(
      id: 12,
      name: 'Egg Hoppers (6 pieces)',
      description: 'Hoppers with a fried egg in the center',
      price: 480,
      sellerId: 1,
      isAvailable: true,
      departmentId: 2,
      subDepartmentId: 5,
    ),

    // String Hoppers (Sub-department 6)
    const FoodItem(
      id: 13,
      name: 'String Hoppers (10 pieces)',
      description: 'Steamed string hoppers with coconut sambol',
      price: 200,
      sellerId: 1,
      isAvailable: true,
      departmentId: 2,
      subDepartmentId: 6,
    ),
    const FoodItem(
      id: 14,
      name: 'String Hoppers (20 pieces)',
      description: 'Steamed string hoppers with coconut sambol',
      price: 380,
      sellerId: 1,
      isAvailable: true,
      departmentId: 2,
      subDepartmentId: 6,
    ),

    // Chicken Kottu (Sub-department 7)
    const FoodItem(
      id: 15,
      name: 'Chicken Kottu',
      description: 'Chopped roti with chicken, vegetables, and spices',
      price: 420,
      sellerId: 1,
      isAvailable: true,
      departmentId: 3,
      subDepartmentId: 7,
    ),
    const FoodItem(
      id: 16,
      name: 'Chicken Kottu (Extra Spicy)',
      description: 'Spicy chicken kottu with extra chili and spices',
      price: 450,
      sellerId: 1,
      isAvailable: true,
      departmentId: 3,
      subDepartmentId: 7,
    ),

    // Vegetable Kottu (Sub-department 8)
    const FoodItem(
      id: 17,
      name: 'Vegetable Kottu',
      description: 'Chopped roti with mixed vegetables and spices',
      price: 350,
      sellerId: 1,
      isAvailable: true,
      departmentId: 3,
      subDepartmentId: 8,
    ),
    const FoodItem(
      id: 18,
      name: 'Cheese Kottu',
      description: 'Vegetable kottu with melted cheese',
      price: 420,
      sellerId: 1,
      isAvailable: true,
      departmentId: 3,
      subDepartmentId: 8,
    ),

    // Roti & Paratha (Sub-department 9)
    const FoodItem(
      id: 19,
      name: 'Plain Roti (3 pieces)',
      description: 'Soft flatbread served with curry',
      price: 120,
      sellerId: 1,
      isAvailable: true,
      departmentId: 3,
      subDepartmentId: 9,
    ),
    const FoodItem(
      id: 20,
      name: 'Chicken Roti',
      description: 'Roti filled with spiced chicken curry',
      price: 180,
      sellerId: 1,
      isAvailable: true,
      departmentId: 3,
      subDepartmentId: 9,
    ),
    const FoodItem(
      id: 21,
      name: 'Egg Roti',
      description: 'Roti filled with scrambled eggs and onions',
      price: 150,
      sellerId: 1,
      isAvailable: true,
      departmentId: 3,
      subDepartmentId: 9,
    ),

    // Tea & Coffee (Sub-department 10)
    const FoodItem(
      id: 22,
      name: 'Ceylon Tea',
      description: 'Traditional Sri Lankan black tea',
      price: 80,
      sellerId: 1,
      isAvailable: true,
      departmentId: 4,
      subDepartmentId: 10,
    ),
    const FoodItem(
      id: 23,
      name: 'Ceylon Coffee',
      description: 'Traditional Sri Lankan coffee',
      price: 120,
      sellerId: 1,
      isAvailable: true,
      departmentId: 4,
      subDepartmentId: 10,
    ),
    const FoodItem(
      id: 24,
      name: 'Milk Tea',
      description: 'Ceylon tea with condensed milk',
      price: 100,
      sellerId: 1,
      isAvailable: true,
      departmentId: 4,
      subDepartmentId: 10,
    ),

    // Fresh Juices (Sub-department 11)
    const FoodItem(
      id: 25,
      name: 'King Coconut Water',
      description: 'Fresh king coconut water',
      price: 150,
      sellerId: 1,
      isAvailable: true,
      departmentId: 4,
      subDepartmentId: 11,
    ),
    const FoodItem(
      id: 26,
      name: 'Wood Apple Juice',
      description: 'Traditional Sri Lankan wood apple juice',
      price: 180,
      sellerId: 1,
      isAvailable: true,
      departmentId: 4,
      subDepartmentId: 11,
    ),
    const FoodItem(
      id: 27,
      name: 'Mango Juice',
      description: 'Fresh mango juice',
      price: 200,
      sellerId: 1,
      isAvailable: true,
      departmentId: 4,
      subDepartmentId: 11,
    ),
    const FoodItem(
      id: 28,
      name: 'Pineapple Juice',
      description: 'Fresh pineapple juice',
      price: 180,
      sellerId: 1,
      isAvailable: true,
      departmentId: 4,
      subDepartmentId: 11,
    ),

    // Traditional Sweets (Sub-department 12)
    const FoodItem(
      id: 29,
      name: 'Kavum',
      description: 'Traditional Sri Lankan oil cake',
      price: 25,
      sellerId: 1,
      isAvailable: true,
      departmentId: 5,
      subDepartmentId: 12,
    ),
    const FoodItem(
      id: 30,
      name: 'Kokis',
      description: 'Crispy deep-fried snack',
      price: 20,
      sellerId: 1,
      isAvailable: true,
      departmentId: 5,
      subDepartmentId: 12,
    ),
    const FoodItem(
      id: 31,
      name: 'Watalappan',
      description: 'Sri Lankan coconut custard pudding',
      price: 180,
      sellerId: 1,
      isAvailable: true,
      departmentId: 5,
      subDepartmentId: 12,
    ),
    const FoodItem(
      id: 32,
      name: 'Kiri Pani',
      description: 'Traditional milk toffee',
      price: 15,
      sellerId: 1,
      isAvailable: true,
      departmentId: 5,
      subDepartmentId: 12,
    ),

    // Ice Cream & Falooda (Sub-department 13)
    const FoodItem(
      id: 33,
      name: 'Coconut Ice Cream',
      description: 'Creamy coconut ice cream',
      price: 150,
      sellerId: 1,
      isAvailable: true,
      departmentId: 5,
      subDepartmentId: 13,
    ),
    const FoodItem(
      id: 34,
      name: 'Falooda',
      description: 'Traditional falooda with ice cream and jelly',
      price: 250,
      sellerId: 1,
      isAvailable: true,
      departmentId: 5,
      subDepartmentId: 13,
    ),
    const FoodItem(
      id: 35,
      name: 'Wood Apple Ice Cream',
      description: 'Wood apple flavored ice cream',
      price: 180,
      sellerId: 1,
      isAvailable: true,
      departmentId: 5,
      subDepartmentId: 13,
    ),
  ];

  // Simulate network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Mock login
  Future<AuthResponse> login(String email, String password) async {
    await _simulateDelay();

    final user = _mockUsers.firstWhere(
      (user) => user.email == email,
      orElse: () => throw Exception('User not found'),
    );

    final storedPassword = _mockPasswords[email];
    if (storedPassword != password) {
      throw Exception('Invalid password');
    }

    // Generate a mock token
    final token =
        'mock_token_${user.id}_${DateTime.now().millisecondsSinceEpoch}';

    return AuthResponse(user: user, token: token);
  }

  // Mock login with password only (for waiter)
  Future<AuthResponse> loginWithPassword(String password) async {
    await _simulateDelay();

    // Find waiter user by password
    final waiterEmail = _mockPasswords.entries
        .firstWhere(
          (entry) => entry.value == password,
          orElse: () => throw Exception('Invalid password'),
        )
        .key;

    final user = _mockUsers.firstWhere(
      (user) => user.email == waiterEmail,
      orElse: () => throw Exception('User not found'),
    );

    // Generate a mock token
    final token =
        'mock_token_${user.id}_${DateTime.now().millisecondsSinceEpoch}';

    return AuthResponse(user: user, token: token);
  }

  // Mock signup
  Future<AuthResponse> signup(AuthRequest request) async {
    await _simulateDelay();

    // Check if user already exists
    if (_mockUsers.any((user) => user.email == request.email)) {
      throw Exception('User already exists');
    }

    // Create new user
    final newUser = AppUser(
      id: _mockUsers.length + 1,
      email: request.email,
      role: request.role ?? 'customer',
      name: request.name,
      phone: request.phone,
      createdAt: DateTime.now(),
    );

    // Add to mock database
    _mockUsers.add(newUser);
    _mockPasswords[request.email] = request.password;

    // Generate a mock token
    final token =
        'mock_token_${newUser.id}_${DateTime.now().millisecondsSinceEpoch}';

    return AuthResponse(user: newUser, token: token);
  }

  // Mock get departments
  Future<List<Department>> getDepartments() async {
    await _simulateDelay();
    return List.from(_mockDepartments);
  }

  // Mock get sub-departments
  Future<List<SubDepartment>> getSubDepartments() async {
    await _simulateDelay();
    return List.from(_mockSubDepartments);
  }

  // Mock get food items
  Future<List<FoodItem>> getFoodItems() async {
    print('MockApiClient: Getting food items...');
    await _simulateDelay();
    print('MockApiClient: Returning ${_mockFoodItems.length} items');
    return List.from(_mockFoodItems);
  }

  // Get food item by ID
  FoodItem? getFoodItem(int foodItemId) {
    try {
      return _mockFoodItems.firstWhere((item) => item.id == foodItemId);
    } catch (e) {
      return null;
    }
  }
}
