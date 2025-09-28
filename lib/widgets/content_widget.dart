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
      print(
        '⏳ ContentWidget: Showing loading state - menu.loading: ${menu.loading}, databaseData.isLoadingMenuItems: ${databaseData.isLoadingMenuItems}, databaseData.isLoadingDepartments: ${databaseData.isLoadingDepartments}',
      );
      return _buildLoadingState(theme);
    }

    // If searching, show search results from database
    if (menu.searchQuery.isNotEmpty) {
      print(
        '🔍 ContentWidget: Showing search results for "${menu.searchQuery}"',
      );
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
      print(
        '🏢 ContentWidget: Showing departments - selectedDepartmentId: ${menu.selectedDepartmentId}, departments count: ${databaseData.departments.length}',
      );
      return _buildDepartments(theme, databaseData);
    }

    // If department selected but no sub-department, show sub-departments from database
    if (menu.selectedSubDepartmentId == null) {
      print(
        '📁 ContentWidget: Showing sub-departments - selectedDepartmentId: ${menu.selectedDepartmentId}, selectedSubDepartmentId: ${menu.selectedSubDepartmentId}',
      );
      return _buildSubDepartments(theme, menu, databaseData);
    }

    // If sub-department selected, show items from database
    print(
      '🍽️ ContentWidget: Showing items - selectedDepartmentId: ${menu.selectedDepartmentId}, selectedSubDepartmentId: ${menu.selectedSubDepartmentId}',
    );
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
    print(
      '🏢 Building departments list: ${databaseData.departments.length} departments',
    );
    if (databaseData.departments.isEmpty) {
      print('⚠️ No departments found in database data');
    }

    return RefreshIndicator(
      onRefresh: () => databaseData.refreshAllData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: databaseData.departments.length,
        itemBuilder: (context, index) {
          final department = databaseData.departments[index];
          print(
            '🏢 Building department card: ${department.name} (${department.departmentCode})',
          );
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
    final subDepartments = databaseData.subDepartments;
    print(
      '📁 Building sub-departments list: ${subDepartments.length} sub-departments for department ${menu.selectedDepartmentId}',
    );

    // Show empty state if no sub-departments
    if (subDepartments.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => databaseData.refreshAllData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: 400,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open_outlined,
                  size: 64,
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Sub-Departments',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This department doesn\'t have any sub-categories yet.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Pull down to refresh',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
    // Use the products that were loaded for the selected sub-department
    List<FoodItem> items = databaseData.menuItems;

    print(
      '🍽️ Building items list: ${items.length} items for sub-department ${menu.selectedSubDepartmentId}',
    );
    if (items.isEmpty) {
      print(
        '⚠️ No items found for sub-department ${menu.selectedSubDepartmentId}',
      );
    }

    // Show empty state if no items
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => databaseData.refreshAllData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: 400,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu_outlined,
                  size: 64,
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Menu Items',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This sub-department doesn\'t have any items available yet.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Pull down to refresh',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
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
        // Show empty state if no search results
        if (items.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => databaseData.refreshAllData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: 400,
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_outlined,
                      size: 64,
                      color: theme.colorScheme.outline.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Results Found',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try searching with different keywords or check your spelling.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pull down to refresh',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
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
      },
    );
  }
}
