import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../providers/database_data_provider.dart';
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
    final databaseData = context.watch<DatabaseDataProvider>();

    // Show loading if either menu or database is loading
    if (menu.loading ||
        databaseData.isLoadingMenuItems ||
        databaseData.isLoadingDepartments) {
      return _buildLoadingState(theme);
    }

    // If searching, show search results from database
    if (menu.searchQuery.isNotEmpty) {
      final searchResults = databaseData.menuItems
          .where(
            (item) => item.name.toLowerCase().contains(
              menu.searchQuery.toLowerCase(),
            ),
          )
          .toList();
      return _buildSearchResults(theme, searchResults);
    }

    // If no department selected, show departments from database
    if (menu.selectedDepartmentId == null) {
      return _buildDepartments(theme, databaseData);
    }

    // If department selected but no sub-department, show sub-departments from database
    if (menu.selectedSubDepartmentId == null) {
      return _buildSubDepartments(theme, menu, databaseData);
    }

    // If sub-department selected, show items from database
    return _buildItems(theme, menu, databaseData);
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
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

  Widget _buildDepartments(ThemeData theme, DatabaseDataProvider databaseData) {
    return RefreshIndicator(
      onRefresh: () => databaseData.refreshAllData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: databaseData.departments.length,
        itemBuilder: (context, index) {
          final department = databaseData.departments[index];
          return DepartmentCardWidget(department: department);
        },
      ),
    );
  }

  Widget _buildSubDepartments(
    ThemeData theme,
    MenuProvider menu,
    DatabaseDataProvider databaseData,
  ) {
    // Load sub-departments for the selected department
    if (menu.selectedDepartmentId != null) {
      databaseData.loadSubDepartments(menu.selectedDepartmentId!.toString());
    }

    final subDepartments = databaseData.subDepartments;

    return RefreshIndicator(
      onRefresh: () => databaseData.refreshAllData(),
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

  Widget _buildItems(
    ThemeData theme,
    MenuProvider menu,
    DatabaseDataProvider databaseData,
  ) {
    // Get items from database based on selected sub-department
    List<FoodItem> items;
    if (menu.selectedSubDepartmentId != null) {
      items = databaseData.getMenuItemsBySubDepartment(
        menu.selectedSubDepartmentId!.toString(),
      );
    } else if (menu.selectedDepartmentId != null) {
      items = databaseData.getMenuItemsByDepartment(
        menu.selectedDepartmentId!.toString(),
      );
    } else {
      items = databaseData.menuItems;
    }

    return RefreshIndicator(
      onRefresh: () => databaseData.refreshAllData(),
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
    return Consumer<DatabaseDataProvider>(
      builder: (context, databaseData, child) {
        return RefreshIndicator(
          onRefresh: () => databaseData.refreshAllData(),
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
