import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/menu_provider.dart';
import '../providers/cart_provider.dart';
import '../models/food_item.dart';
import '../models/department.dart';
import '../models/sub_department.dart';

class WaiterDashboard extends StatefulWidget {
  const WaiterDashboard({super.key});

  @override
  State<WaiterDashboard> createState() => _WaiterDashboardState();
}

class _WaiterDashboardState extends State<WaiterDashboard> {
  final TextEditingController _searchController = TextEditingController();
  bool _isMenuMode = true; // true for menu, false for orders
  
  // Mock table data
  final List<Map<String, dynamic>> _tables = [
    {'id': 1, 'number': 'Table 1', 'isPaid': false, 'total': 1250, 'items': 3},
    {'id': 2, 'number': 'Table 2', 'isPaid': true, 'total': 890, 'items': 2},
    {'id': 3, 'number': 'Table 3', 'isPaid': false, 'total': 2100, 'items': 5},
    {'id': 4, 'number': 'Table 4', 'isPaid': true, 'total': 0, 'items': 0},
    {'id': 5, 'number': 'Table 5', 'isPaid': false, 'total': 750, 'items': 2},
    {'id': 6, 'number': 'Table 6', 'isPaid': true, 'total': 0, 'items': 0},
    {'id': 7, 'number': 'Table 7', 'isPaid': false, 'total': 1650, 'items': 4},
    {'id': 8, 'number': 'Table 8', 'isPaid': true, 'total': 0, 'items': 0},
  ];

  @override
  void initState() {
    super.initState();
    // Load menu data when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().loadMenuData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final menu = context.watch<MenuProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      floatingActionButton: cart.isEmpty
        ? null
        : Container(
            margin: const EdgeInsets.all(16),
            child: FloatingActionButton.extended(
              onPressed: () => _showFullscreenTable(context, cart, theme),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              icon: const Icon(Icons.check_rounded),
              label: const Text(
                'Confirm Order',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.surface,
              theme.colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern Header
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          auth.currentUser?.name ?? 'Waiter',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.restaurant,
                            color: theme.colorScheme.onPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () async {
                            await auth.logout();
                            if (mounted) {
                              Navigator.of(context).pushReplacementNamed('/');
                            }
                          },
                          icon: Icon(
                            Icons.logout_rounded,
                            color: theme.colorScheme.onPrimary,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.onPrimary
                                .withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Real-time Table Section - Right after welcome back
              Container(
                height:
                    MediaQuery.of(context).size.height *
                    0.35, // 35% of screen height
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.1),
                            theme.colorScheme.primary.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Title and Clear All Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Current Order',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                                ),
                              ),
                              if (!cart.isEmpty)
                                TextButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        title: const Text('Clear All Items'),
                                        content: const Text(
                                          'Are you sure you want to remove all items from the order?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              cart.clearCart();
                                              Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  theme.colorScheme.error,
                                              foregroundColor:
                                                  theme.colorScheme.onError,
                                            ),
                                            child: const Text('Clear All'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.clear_all_rounded,
                                    size: 18,
                                    color: theme.colorScheme.error,
                                  ),
                                  label: Text(
                                    'Clear All',
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor: theme.colorScheme.error
                                        .withOpacity(0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Table Headers
                          Row(
                            children: [
                              Expanded(flex: 1, child: _buildTableHeader('#')),
                              Expanded(
                                flex: 2,
                                child: _buildTableHeader('Item'),
                              ),
                              Expanded(
                                flex: 1,
                                child: _buildTableHeader('Price (Rs.)'),
                              ),
                              Expanded(
                                flex: 1,
                                child: _buildTableHeader('Qty'),
                              ),
                              Expanded(
                                flex: 1,
                                child: _buildTableHeader('Disc%'),
                              ),
                              Expanded(
                                flex: 1,
                                child: _buildTableHeader('Service (Rs.)'),
                              ),
                              Expanded(
                                flex: 1,
                                child: _buildTableHeader('Total (Rs.)'),
                              ),
                              Expanded(
                                flex: 1,
                                child: _buildTableHeader('Del'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Table Body
                    Expanded(
                      child: cart.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 48,
                                    color: theme.colorScheme.outline
                                        .withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No items added yet',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.outline
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add items from the menu below',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.outline
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: cart.items.length,
                              itemBuilder: (context, index) {
                                final item = cart.items[index];
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: theme.colorScheme.outline
                                            .withOpacity(0.1),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '${index + 1}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          item.foodItem.name,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '${item.foodItem.price.toStringAsFixed(0)}',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '${item.quantity}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '0%',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '${cart.serviceCharge.toStringAsFixed(0)}',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '${item.totalPrice.toStringAsFixed(0)}',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: IconButton(
                                          onPressed: () {
                                            cart.removeItemByIndex(index);
                                          },
                                          icon: Icon(
                                            Icons.delete_outline_rounded,
                                            color: theme.colorScheme.error,
                                            size: 20,
                                          ),
                                          style: IconButton.styleFrom(
                                            backgroundColor: theme
                                                .colorScheme
                                                .error
                                                .withOpacity(0.1),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.all(8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    // Total Row
                    if (!cart.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.05),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Spacer(),
                            Text(
                              'Total: Rs.${cart.total.toStringAsFixed(0)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Menu/Orders Toggle - Right after table section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isMenuMode = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isMenuMode 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.surface,
                          foregroundColor: _isMenuMode 
                              ? theme.colorScheme.onPrimary 
                              : theme.colorScheme.onSurface,
                          elevation: _isMenuMode ? 4 : 1,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu_rounded,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text('Menu'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isMenuMode = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !_isMenuMode 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.surface,
                          foregroundColor: !_isMenuMode 
                              ? theme.colorScheme.onPrimary 
                              : theme.colorScheme.onSurface,
                          elevation: !_isMenuMode ? 4 : 1,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.table_restaurant_rounded,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text('Orders'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Search Bar (only show in menu mode)
              if (_isMenuMode) ...[
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search menu items...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear_rounded,
                                color: theme.colorScheme.primary,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                menu.setSearchQuery('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      menu.setSearchQuery(value);
                    },
                  ),
                ),
              ],
              const SizedBox(height: 4),
              // Navigation Breadcrumb (only show in menu mode)
              if (_isMenuMode && (menu.selectedDepartmentId != null ||
                  menu.selectedSubDepartmentId != null)) ...[
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => menu.clearSelection(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.home_rounded,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'All',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (menu.selectedDepartmentId != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => menu.selectDepartment(null),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withOpacity(
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  menu.getDepartmentName(
                                    menu.selectedDepartmentId!,
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (menu.selectedSubDepartmentId != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                menu.getSubDepartmentName(
                                  menu.selectedSubDepartmentId!,
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.tertiary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 4),
              // Content Section
              Expanded(
                child: _isMenuMode 
                    ? (menu.loading
                        ? Center(
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
                          )
                        : _buildContent(theme, menu))
                    : _buildOrdersView(theme),
              ),
          ],
        ),
      ),
    );
  }

  void _showFullscreenTable(
    BuildContext context,
    CartProvider cart,
    ThemeData theme,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Material(
          color: Colors.transparent,
                      child: Container(
            width: double.infinity,
            height: double.infinity,
                        decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                            color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Summary',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close_rounded,
                            color: theme.colorScheme.outline,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.outline
                                .withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Table
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Table Header
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary.withOpacity(0.1),
                                  theme.colorScheme.primary.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: _buildTableHeader('#'),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: _buildTableHeader('Item'),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: _buildTableHeader('Price (Rs.)'),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: _buildTableHeader('Qty'),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: _buildTableHeader('Disc%'),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: _buildTableHeader('Service (Rs.)'),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: _buildTableHeader('Total (Rs.)'),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: _buildTableHeader('Del'),
                                ),
                              ],
                            ),
                          ),
                          // Table Body
                          Expanded(
                            child: ListView.builder(
                              itemCount: cart.items.length,
                              itemBuilder: (context, index) {
                                final item = cart.items[index];
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: theme.colorScheme.outline
                                            .withOpacity(0.1),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '${index + 1}',
                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          item.foodItem.name,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '${item.foodItem.price.toStringAsFixed(0)}',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '${item.quantity}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '0%',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '${cart.serviceCharge.toStringAsFixed(0)}',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '${item.totalPrice.toStringAsFixed(0)}',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: IconButton(
                                          onPressed: () {
                                            cart.removeItemByIndex(index);
                                          },
                                          icon: Icon(
                                            Icons.delete_outline_rounded,
                                            color: theme.colorScheme.error,
                                            size: 20,
                                          ),
                                          style: IconButton.styleFrom(
                                            backgroundColor: theme
                                                .colorScheme
                                                .error
                                                .withOpacity(0.1),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ),
                ],
              ),
                                );
                              },
                            ),
                          ),
                          // Total Row
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(
                                0.05,
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Spacer(),
                                Text(
                                  'Total: Rs.${cart.total.toStringAsFixed(0)}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Action Buttons
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.outline
                                  .withOpacity(0.1),
                              foregroundColor: theme.colorScheme.outline,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text('Continue Shopping'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Here you can add order confirmation logic
                              Navigator.of(context).pop();
                              _showOrderConfirmation(context, theme, cart);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text('Confirm Order'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        );
      },
    );
  }

  void _showOrderConfirmation(
    BuildContext context,
    ThemeData theme,
    CartProvider cart,
  ) {
    final seatController = TextEditingController();
    final remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.restaurant_rounded,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Order Details'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please provide the following details to complete the order:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              // Seat Number Input
              TextField(
                controller: seatController,
                decoration: InputDecoration(
                  labelText: 'Seat Number *',
                  hintText: 'e.g., Table 5, Seat 2',
                  prefixIcon: Icon(
                    Icons.chair_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              // Remarks/Special Requests Input
              TextField(
                controller: remarksController,
                decoration: InputDecoration(
                  labelText: 'Special Requests / Remarks',
                  hintText: 'e.g., No spice, Extra sauce, etc.',
                  prefixIcon: Icon(
                    Icons.note_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 16),
              // Order Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Rs.${cart.total.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (seatController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter seat number'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Here you can save the order with seat number and remarks
              // For now, we'll just show a success message
              Navigator.of(context).pop();

              // Show success dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Text('Order Confirmed!'),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Your order has been sent to the kitchen successfully.',
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Seat: ${seatController.text.trim()}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (remarksController.text.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Remarks: ${remarksController.text.trim()}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        // Clear the cart after order confirmation
                        cart.clearCart();
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirm Order'),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 0.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOrdersView(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Table Status',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _tables.length,
              itemBuilder: (context, index) {
                final table = _tables[index];
                final isPaid = table['isPaid'] as bool;
                final total = table['total'] as int;
                final items = table['items'] as int;
                
                return GestureDetector(
                  onTap: isPaid ? null : () => _showTableDetails(context, theme, table),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isPaid 
                            ? [Colors.green.shade100, Colors.green.shade50]
                            : [Colors.red.shade100, Colors.red.shade50],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isPaid ? Colors.green.shade400 : Colors.red.shade400,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isPaid ? Colors.green : Colors.red).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isPaid ? Colors.green.shade600 : Colors.red.shade600,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isPaid ? Colors.green : Colors.red).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            isPaid ? Icons.check_circle_rounded : Icons.restaurant_rounded,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          table['number'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isPaid ? Colors.green.shade800 : Colors.red.shade800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPaid ? Colors.green.shade600 : Colors.red.shade600,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isPaid ? 'PAID' : 'UNPAID',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (!isPaid && total > 0) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Rs.$total',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade800,
                                  ),
                                ),
                                Text(
                                  '${items} items',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTableDetails(BuildContext context, ThemeData theme, Map<String, dynamic> table) {
    final cart = context.read<CartProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.table_restaurant_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(table['number']),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status and Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                        ),
                        Text(
                          'Unpaid',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                        ),
                        Text(
                          'Rs.${table['total']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Items:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                        ),
                        Text(
                          '${table['items']} items',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Order Details Section
              if (cart.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 48,
                        color: theme.colorScheme.outline.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No items in current order',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add items from the menu to see order details',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Order Items List
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: _buildTableHeader('Item')),
                            Expanded(flex: 1, child: _buildTableHeader('Qty')),
                            Expanded(flex: 1, child: _buildTableHeader('Price')),
                            Expanded(flex: 1, child: _buildTableHeader('Total')),
                          ],
                        ),
                      ),
                      // Items
                      Expanded(
                        child: ListView.builder(
                          itemCount: cart.items.length,
                          itemBuilder: (context, index) {
                            final item = cart.items[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: theme.colorScheme.outline.withOpacity(0.1),
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      item.foodItem.name,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${item.quantity}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'Rs.${item.foodItem.price.toStringAsFixed(0)}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'Rs.${item.totalPrice.toStringAsFixed(0)}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      // Total
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.05),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Text(
                              'Rs.${cart.total.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (!cart.isEmpty)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Switch to menu mode to show the current order
                setState(() {
                  _isMenuMode = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('View Full Order'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Here you can add logic to process payment
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mark as Paid'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, MenuProvider menu) {
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

  Widget _buildDepartments(ThemeData theme, MenuProvider menu) {
    return RefreshIndicator(
      onRefresh: () => menu.loadMenuData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: menu.departments.length,
        itemBuilder: (context, index) {
          final department = menu.departments[index];
          return _buildDepartmentCard(department, theme, menu);
        },
      ),
    );
  }

  Widget _buildDepartmentCard(
    Department department,
    ThemeData theme,
    MenuProvider menu,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
      child: InkWell(
        onTap: () => menu.selectDepartment(department.id),
          borderRadius: BorderRadius.circular(20),
        child: Padding(
            padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              // Department Icon
              Container(
                  width: 70,
                  height: 70,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                ),
                child: Center(
                  child: Text(
                    department.icon ?? '🍽️',
                      style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
                const SizedBox(width: 20),
              // Department Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      department.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (department.description != null) ...[
                        const SizedBox(height: 6),
                      Text(
                        department.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                            height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
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
          return _buildSubDepartmentCard(subDepartment, theme, menu);
        },
      ),
    );
  }

  Widget _buildSubDepartmentCard(
    SubDepartment subDepartment,
    ThemeData theme,
    MenuProvider menu,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
      child: InkWell(
        onTap: () => menu.selectSubDepartment(subDepartment.id),
          borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Sub-Department Icon
              Container(
                  width: 60,
                  height: 60,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.secondary,
                        theme.colorScheme.secondary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.secondary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                ),
                child: Center(
                  child: Text(
                    subDepartment.icon ?? '🍽️',
                      style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
                const SizedBox(width: 18),
              // Sub-Department Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subDepartment.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (subDepartment.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subDepartment.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                            height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
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
          return _buildFoodItemCard(foodItem, theme);
        },
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme, List<FoodItem> items) {
    return RefreshIndicator(
      onRefresh: () => context.read<MenuProvider>().loadMenuData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final foodItem = items[index];
          return _buildFoodItemCard(foodItem, theme);
        },
      ),
    );
  }

  Widget _buildFoodItemCard(FoodItem foodItem, ThemeData theme) {
    final cart = context.watch<CartProvider>();
    final isInCart = cart.isItemInCart(foodItem);
    final quantity = cart.getItemQuantity(foodItem);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Food Icon
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.1),
                        theme.colorScheme.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    _getFoodIcon(foodItem.name),
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 18),
                // Food Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        foodItem.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        foodItem.description ?? 'No description available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Price and Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rs.${foodItem.price.toStringAsFixed(0)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                // Add/Remove Buttons
                if (isInCart)
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () =>
                            cart.updateQuantity(foodItem, quantity - 1),
                          icon: Icon(
                            Icons.remove_rounded,
                        color: theme.colorScheme.error,
                      ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                        '$quantity',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            cart.updateQuantity(foodItem, quantity + 1),
                          icon: Icon(
                            Icons.add_rounded,
                        color: theme.colorScheme.primary,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => cart.addItem(foodItem),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add to Table'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Availability Status
            Row(
              children: [
                _buildAvailabilityChip(
                  'Available',
                  foodItem.isAvailable,
                  theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityChip(
    String label,
    bool isAvailable,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAvailable
              ? [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.primary.withOpacity(0.05),
                ]
              : [
                  theme.colorScheme.outline.withOpacity(0.1),
                  theme.colorScheme.outline.withOpacity(0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAvailable
              ? theme.colorScheme.primary.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
          color: isAvailable
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
              shape: BoxShape.circle,
        ),
      ),
          const SizedBox(width: 8),
          Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isAvailable
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
              fontWeight: FontWeight.w600,
        ),
          ),
        ],
      ),
    );
  }

  IconData _getFoodIcon(String foodName) {
    final name = foodName.toLowerCase();
    if (name.contains('pizza')) return Icons.local_pizza;
    if (name.contains('burger')) return Icons.lunch_dining;
    if (name.contains('salad')) return Icons.eco;
    if (name.contains('pasta')) return Icons.ramen_dining;
    if (name.contains('cake') || name.contains('dessert')) return Icons.cake;
    if (name.contains('coffee') || name.contains('hot'))
      return Icons.local_cafe;
    if (name.contains('juice') || name.contains('cola'))
      return Icons.local_drink;
    if (name.contains('ice cream')) return Icons.icecream;
    if (name.contains('soup')) return Icons.soup_kitchen;
    if (name.contains('wings') || name.contains('sticks'))
      return Icons.restaurant;
    return Icons.restaurant;
  }
}
