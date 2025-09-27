import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../models/food_item.dart';
import 'department_card_widget.dart';
import 'sub_department_card_widget.dart';
import 'food_item_card_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final menu = context.watch<MenuProvider>();

    if (menu.loading) {
      return _buildLoadingState(theme);
    }

    // If searching, show search results
    if (menu.searchQuery.isNotEmpty) {
      final searchResults = menu.getAllFoodItems();
      return _buildSearchResults(theme, searchResults);
    }

    // If no department selected, show departments
    if (menu.selectedDepartmentId == null) {
      return _buildDepartments(theme, menu);
    }

    // If department selected but no sub-department, show sub-departments
    if (menu.selectedSubDepartmentId == null) {
      return _buildSubDepartments(theme, menu);
    }

    // If sub-department selected, show items
    return _buildItems(theme, menu);
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading menu...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartments(ThemeData theme, MenuProvider menu) {
    return RefreshIndicator(
      onRefresh: () => menu.loadMenuData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: menu.departments.length,
        itemBuilder: (context, index) {
          final department = menu.departments[index];
          return DepartmentCardWidget(department: department);
        },
      ),
    );
  }

  Widget _buildSubDepartments(ThemeData theme, MenuProvider menu) {
    final subDepartments = menu.getSubDepartmentsForSelected();

    return RefreshIndicator(
      onRefresh: () => menu.loadMenuData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subDepartments.length,
        itemBuilder: (context, index) {
          final subDepartment = subDepartments[index];
          return SubDepartmentCardWidget(subDepartment: subDepartment);
        },
      ),
    );
  }

  Widget _buildItems(ThemeData theme, MenuProvider menu) {
    final items = menu.getFilteredFoodItems();

    return RefreshIndicator(
      onRefresh: () => menu.loadMenuData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final foodItem = items[index];
          return FoodItemCardWidget(foodItem: foodItem);
        },
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme, List<FoodItem> items) {
    return Consumer<MenuProvider>(
      builder: (context, menu, child) {
        return RefreshIndicator(
          onRefresh: () => menu.loadMenuData(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final foodItem = items[index];
              return FoodItemCardWidget(foodItem: foodItem);
            },
          ),
        );
      },
    );
  }
}
