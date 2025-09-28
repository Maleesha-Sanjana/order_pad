import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/database_data_provider.dart';

class OrdersViewWidget extends StatelessWidget {
  const OrdersViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<DatabaseDataProvider>(
      builder: (context, databaseData, child) {
        // Load orders if not already loaded
        if (databaseData.orders.isEmpty && !databaseData.isLoadingOrders) {
          databaseData.loadOrders();
        }

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
                    'Table Status',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Orders Grid
              Expanded(
                child: databaseData.isLoadingOrders
                    ? const Center(child: CircularProgressIndicator())
                    : databaseData.orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.table_restaurant_outlined,
                              size: 64,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No orders found',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Orders will appear here when customers place them',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.5,
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
                        itemCount: databaseData.orders.length,
                        itemBuilder: (context, index) {
                          final order = databaseData.orders[index];
                          final isPaid =
                              order.status.toLowerCase() == 'paid' ||
                              order.status.toLowerCase() == 'completed';

                          return GestureDetector(
                            onTap: isPaid
                                ? null
                                : () =>
                                      _showOrderDetails(context, theme, order),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isPaid
                                      ? [
                                          Colors.green.shade100,
                                          Colors.green.shade50,
                                        ]
                                      : [
                                          Colors.red.shade100,
                                          Colors.red.shade50,
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isPaid
                                      ? Colors.green.shade400
                                      : Colors.red.shade400,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isPaid ? Colors.green : Colors.red)
                                        .withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
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
                                        color: isPaid
                                            ? Colors.green.shade600
                                            : Colors.red.shade600,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.table_restaurant,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Table Number
                                    Text(
                                      'Table ${order.tableNumber}',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isPaid
                                                ? Colors.green.shade800
                                                : Colors.red.shade800,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Status
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isPaid
                                            ? Colors.green.shade600
                                            : Colors.red.shade600,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        order.status.toUpperCase(),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                      ),
                                    ),
                                  ],
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

  void _showOrderDetails(BuildContext context, ThemeData theme, dynamic order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.table_restaurant, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('Table ${order.tableNumber}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    order.status.toLowerCase() == 'paid' ||
                        order.status.toLowerCase() == 'completed'
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      order.status.toLowerCase() == 'paid' ||
                          order.status.toLowerCase() == 'completed'
                      ? Colors.green.shade400
                      : Colors.red.shade400,
                ),
              ),
              child: Text(
                'Status: ${order.status.toUpperCase()}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      order.status.toLowerCase() == 'paid' ||
                          order.status.toLowerCase() == 'completed'
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (order.remarks != null && order.remarks.isNotEmpty) ...[
              Text(
                'Remarks:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(order.remarks, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
