import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/database_data_provider.dart';
import '../providers/cart_provider.dart';
import '../models/suspend_order.dart';
import '../models/service_type.dart';
import '../models/food_item.dart';

class TakeawayViewWidget extends StatelessWidget {
  const TakeawayViewWidget({super.key});

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

        // Filter takeaway orders ONLY by BatchNo = 'Takeaway'
        // This ensures complete separation between Takeaway and DineIn sections
        final takeawayOrders = databaseData.suspendOrders
            .where((order) => order.batchNo == 'Takeaway')
            .toList();

        // Group orders by table number (similar to dine-in orders)
        final Map<String, List<SuspendOrder>> groupedOrders = {};
        for (final order in takeawayOrders) {
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
                    Icons.shopping_bag,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Unpaid Takeaways',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
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
              // Orders Grid
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
                              'Loading takeaways...',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
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
                              Icons.shopping_bag_outlined,
                              size: 64,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No unpaid takeaways',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
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
                          final orders = groupedOrders[tableNumber] ?? [];

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _showOrderDetailsDialog(
                                context,
                                theme,
                                tableNumber,
                                orders,
                                databaseData,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.green.shade100,
                                      Colors.green.shade50,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.green.shade400,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.3),
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
                                      // Takeaway Icon
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade600,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.shopping_bag,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Table Number
                                      Text(
                                        'Table ${tableNumber}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade800,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 2),
                                      // Item count
                                      Text(
                                        '${orders.length} ${orders.length == 1 ? 'item' : 'items'}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.green.shade700,
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

  void _showOrderDetailsDialog(
    BuildContext context,
    ThemeData theme,
    String tableNumber,
    List<SuspendOrder> orders,
    DatabaseDataProvider databaseData,
  ) {
    final firstOrder = orders.first;
    final receiptNo = firstOrder.receiptNo?.isNotEmpty == true
        ? firstOrder.receiptNo!
        : null;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.shopping_bag,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text('Table $tableNumber')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add more items to this takeaway order?',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '${orders.length} existing ${orders.length == 1 ? 'item' : 'items'}',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();

              // Load existing orders into cart and mark them as existing
              final cartProvider = Provider.of<CartProvider>(
                context,
                listen: false,
              );

              // Clear cart first
              cartProvider.clearCart();

              // Load existing items into cart (marked as read-only)
              for (final order in orders) {
                final foodItem = FoodItem(
                  idx: order.id ?? 0,
                  productCode: order.productCode,
                  productName: order.productDescription,
                  unitPrice: order.unitPrice,
                  departmentCode: '',
                  subDepartmentCode: '',
                );
                cartProvider.addItem(
                  foodItem,
                  quantity: order.qty.toInt(),
                  isExisting: true, // Mark as existing (read-only)
                );
              }

              // Mark current items count as existing (don't send to backend)
              cartProvider.setExistingItemsCount(orders.length);

              // Set existing receipt number
              if (receiptNo != null) {
                cartProvider.setExistingReceiptNo(receiptNo);
              }

              // Set table number
              cartProvider.setCustomerInfo(tableNumber: firstOrder.table);

              // Set service type to takeaway
              cartProvider.setServiceType(ServiceType.takeaway);

              // Show notification
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${orders.length} existing items loaded. Add new items now!',
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
}
