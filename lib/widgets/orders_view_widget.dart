import 'package:flutter/material.dart';

class OrdersViewWidget extends StatelessWidget {
  const OrdersViewWidget({super.key});

  // Mock table data
  final List<Map<String, dynamic>> _tables = const [
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  onTap: isPaid
                      ? null
                      : () => _showTableDetails(context, theme, table),
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
                        color: isPaid
                            ? Colors.green.shade400
                            : Colors.red.shade400,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isPaid ? Colors.green : Colors.red)
                              .withOpacity(0.3),
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
                            color: isPaid
                                ? Colors.green.shade600
                                : Colors.red.shade600,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isPaid ? Colors.green : Colors.red)
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            isPaid
                                ? Icons.check_circle_rounded
                                : Icons.restaurant_rounded,
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
                            color: isPaid
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                        const SizedBox(height: 6),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
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

  void _showTableDetails(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> table,
  ) {
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
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
}
