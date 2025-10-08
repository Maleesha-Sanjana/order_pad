import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/database_data_provider.dart';
import '../providers/cart_provider.dart';
import '../models/suspend_order.dart';
import '../models/service_type.dart';
import '../models/food_item.dart';

class OrdersViewWidget extends StatelessWidget {
  const OrdersViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<DatabaseDataProvider>(
      builder: (context, databaseData, child) {
        // Load suspend orders only once if not already loaded
        if (!databaseData.suspendOrdersLoaded &&
            !databaseData.isLoadingSuspendOrders) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            databaseData.loadSuspendOrders();
          });
        }

        // Filter table orders (starting with "T")
        final tableOrders = databaseData.suspendOrders
            .where((order) => order.table.startsWith('T'))
            .toList();

        // Group orders by table
        final Map<String, List<SuspendOrder>> groupedOrders = {};
        for (final order in tableOrders) {
          if (!groupedOrders.containsKey(order.table)) {
            groupedOrders[order.table] = [];
          }
          groupedOrders[order.table]!.add(order);
        }

        final unpaidTables = groupedOrders.keys.toList()..sort();

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.table_restaurant,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Unpaid Tables',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  // Refresh Button
                  IconButton(
                    onPressed: () {
                      databaseData.loadSuspendOrders();
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: theme.colorScheme.primary,
                    ),
                    tooltip: 'Refresh Tables',
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${unpaidTables.length}',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Tables Grid
              Expanded(
                child: databaseData.isLoadingSuspendOrders
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading unpaid tables...',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      )
                    : unpaidTables.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.table_restaurant_outlined,
                                  size: 64,
                                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No unpaid tables',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: unpaidTables.length,
                        itemBuilder: (context, index) {
                          final tableNumber = unpaidTables[index];
                          final tableOrders = groupedOrders[tableNumber] ?? [];

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _showTableOrdersDialog(
                                context,
                                theme,
                                tableNumber,
                                tableOrders,
                                databaseData,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.orange.shade100,
                                      Colors.orange.shade50,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.orange.shade400,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Table Icon
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade600,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.table_restaurant,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Table Number
                                      Text(
                                        'Table ${tableNumber.substring(1)}', // Remove "T" prefix
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade800,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      // Item count
                                      Text(
                                        '${tableOrders.length} ${tableOrders.length == 1 ? 'item' : 'items'}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.orange.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTableOrdersDialog(
    BuildContext context,
    ThemeData theme,
    String tableNumber,
    List<SuspendOrder> tableOrders,
    DatabaseDataProvider databaseData,
  ) {
    // Get the receipt number from the first order
    final receiptNo = tableOrders.isNotEmpty ? tableOrders.first.receiptNo : '';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.table_restaurant, color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Table ${tableNumber.substring(1)}'),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Order Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    // Receipt Number
                    if (receiptNo != null && receiptNo.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Receipt: $receiptNo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: theme.colorScheme.primary.withOpacity(0.2)),
                      const SizedBox(height: 12),
                    ],
                    // Items count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_basket,
                          size: 20,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${tableOrders.length} ${tableOrders.length == 1 ? 'item' : 'items'}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Total amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payments,
                          size: 20,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Total: Rs. ${tableOrders.fold<double>(0, (sum, order) => sum + order.amount).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Do you want to add more items to this order?',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
          if (receiptNo != null && receiptNo.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Show receipt details in a new dialog
                _showReceiptDetailsDialog(
                  context,
                  theme,
                  tableNumber,
                  tableOrders,
                  receiptNo,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.receipt),
              label: const Text('View Receipt'),
            ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              
              // Load existing orders into cart and mark them as existing
              final cartProvider = Provider.of<CartProvider>(context, listen: false);
              
              // Clear cart first
              cartProvider.clearCart();
              
              // Load existing items into cart
              for (final order in tableOrders) {
                final foodItem = FoodItem(
                  idx: order.id ?? 0,
                  productCode: order.productCode,
                  productName: order.productDescription,
                  unitPrice: order.unitPrice,
                  departmentCode: '',
                  subDepartmentCode: '',
                );
                cartProvider.addItem(foodItem, quantity: order.qty.toInt());
              }
              
              // Mark current items count as existing (don't send to backend)
              cartProvider.setExistingItemsCount(tableOrders.length);
              
              // Set existing receipt number
              cartProvider.setExistingReceiptNo(receiptNo);
              
              // Set table number
              cartProvider.setCustomerInfo(tableNumber: tableNumber);
              
              // Set service type
              cartProvider.setServiceType(ServiceType.dineIn);
              
              // Show notification
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${tableOrders.length} existing items loaded. Add new items now!',
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green.shade600,
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Add Items'),
          ),
        ],
      ),
    );
  }

  void _showReceiptDetailsDialog(
    BuildContext context,
    ThemeData theme,
    String tableNumber,
    List<SuspendOrder> tableOrders,
    String receiptNo,
  ) {
    final total = tableOrders.fold<double>(0, (sum, order) => sum + order.amount);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, color: theme.colorScheme.primary, size: 32),
                const SizedBox(width: 12),
                Text('Order Receipt'),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                receiptNo,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Table info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.table_restaurant, color: Colors.orange.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Table ${tableNumber.substring(1)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Items list
              Text(
                'Items:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Column(
                    children: tableOrders.map((order) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Quantity badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${order.qty.toInt()}x',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Product name
                            Expanded(
                              child: Text(
                                order.productDescription,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            // Amount
                            Text(
                              'Rs. ${order.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: theme.colorScheme.outline),
              const SizedBox(height: 8),
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Rs. ${total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement print receipt functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Print receipt: $receiptNo'),
                  backgroundColor: Colors.green.shade600,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.print),
            label: const Text('Print'),
          ),
        ],
      ),
    );
  }
}
