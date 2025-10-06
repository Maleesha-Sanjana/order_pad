import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/database_data_provider.dart';
import '../models/suspend_order.dart';

class RoomServiceViewWidget extends StatelessWidget {
  const RoomServiceViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<DatabaseDataProvider>(
      builder: (context, databaseData, child) {
        // Load suspend orders if not already loaded
        if (databaseData.suspendOrders.isEmpty &&
            !databaseData.isLoadingSuspendOrders) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            databaseData.loadSuspendOrders();
          });
        }

        // Filter room orders (starting with "R")
        final roomOrders = databaseData.suspendOrders
            .where((order) => order.table.startsWith('R'))
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
                  // Refresh Button
                  IconButton(
                    onPressed: () {
                      databaseData.loadSuspendOrders();
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: theme.colorScheme.primary,
                    ),
                    tooltip: 'Refresh Rooms',
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
                                  color: theme.colorScheme.onSurface.withOpacity(
                                    0.3,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No unpaid rooms',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'All rooms are paid or no orders found',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    databaseData.loadSuspendOrders();
                                  },
                                  icon: Icon(Icons.refresh),
                                  label: Text('Refresh'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: Colors.white,
                                  ),
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

                          return Container(
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
                                  const SizedBox(height: 12),
                                  // Room Number
                                  Text(
                                    'Room ${roomNumber.substring(1)}', // Remove "R" prefix
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800,
                                        ),
                                  ),
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
      },
    );
  }
}
