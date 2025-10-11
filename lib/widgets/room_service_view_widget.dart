import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/database_data_provider.dart';
import '../providers/cart_provider.dart';
import '../models/suspend_order.dart';
import '../models/service_type.dart';
import '../models/food_item.dart';

class RoomServiceViewWidget extends StatelessWidget {
  const RoomServiceViewWidget({super.key});

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

        // Filter room orders (starting with "R") and BatchNo = 'RoomService'
        final roomOrders = databaseData.suspendOrders
            .where((order) => 
                order.table.startsWith('R') || 
                order.batchNo == 'RoomService')
            .toList();

        // Group orders by room
        final Map<String, List<SuspendOrder>> groupedOrders = {};
        for (final order in roomOrders) {
          if (!groupedOrders.containsKey(order.table)) {
            groupedOrders[order.table] = [];
          }
          groupedOrders[order.table]!.add(order);
        }

        final unpaidRooms = groupedOrders.keys.toList()..sort();

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.hotel, color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Unpaid Rooms',
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
                      '${unpaidRooms.length}',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Rooms Grid
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
                              'Loading unpaid rooms...',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      )
                    : unpaidRooms.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.hotel_outlined,
                                  size: 64,
                                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No unpaid rooms',
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
                        itemCount: unpaidRooms.length,
                        itemBuilder: (context, index) {
                          final roomNumber = unpaidRooms[index];
                          final roomOrders = groupedOrders[roomNumber] ?? [];

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _showRoomOrdersDialog(
                                context,
                                theme,
                                roomNumber,
                                roomOrders,
                                databaseData,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.blue.shade100,
                                      Colors.blue.shade50,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.blue.shade400,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
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
                                      // Room Icon
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade600,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.hotel,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Room Number
                                      Text(
                                        'Room ${roomNumber.substring(1)}', // Remove "R" prefix
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      // Item count
                                      Text(
                                        '${roomOrders.length} ${roomOrders.length == 1 ? 'item' : 'items'}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.blue.shade700,
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

  void _showRoomOrdersDialog(
    BuildContext context,
    ThemeData theme,
    String roomNumber,
    List<SuspendOrder> roomOrders,
    DatabaseDataProvider databaseData,
  ) {
    // Get the receipt number from the first order
    final receiptNo = roomOrders.isNotEmpty ? roomOrders.first.receiptNo : '';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.hotel, color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Room ${roomNumber.substring(1)}'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add items to this room?',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '${roomOrders.length} existing ${roomOrders.length == 1 ? 'item' : 'items'}',
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
              
              // Load existing orders into cart
              final cartProvider = Provider.of<CartProvider>(context, listen: false);
              
              // Clear cart first
              cartProvider.clearCart();
              
              // Load existing items into cart (marked as read-only)
              for (final order in roomOrders) {
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
              
              // Mark current items count as existing
              cartProvider.setExistingItemsCount(roomOrders.length);
              
              // Set existing receipt number
              cartProvider.setExistingReceiptNo(receiptNo);
              
              // Set room number
              cartProvider.setCustomerInfo(tableNumber: roomNumber);
              
              // Set service type to room service
              cartProvider.setServiceType(ServiceType.roomService);
              
              // Show notification
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${roomOrders.length} existing items loaded. Add new items now!',
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
