import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../services/mock_api_client.dart';

class CatalogProvider extends ChangeNotifier {
  final MockApiClient mockApiClient;
  List<FoodItem> _items = const [];
  bool _loading = false;

  List<FoodItem> get items => _items;
  bool get loading => _loading;

  CatalogProvider()
    : mockApiClient = MockApiClient();

  Future<void> fetch() async {
    print('CatalogProvider: Starting fetch...');
    _loading = true;
    notifyListeners();
    try {
      // Use mock API client for testing
      _items = await mockApiClient.getFoodItems();
      print('CatalogProvider: Fetched ${_items.length} items');
      if (_items.isNotEmpty) {
        print('CatalogProvider: First item: ${_items.first.name}');
      }
    } catch (e) {
      print('CatalogProvider: Error fetching items: $e');
      _items = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
