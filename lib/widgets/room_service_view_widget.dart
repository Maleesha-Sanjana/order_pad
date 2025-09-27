import 'package:flutter/material.dart';

class RoomServiceViewWidget extends StatelessWidget {
  const RoomServiceViewWidget({super.key});

  // Mock room data
  final List<Map<String, dynamic>> _rooms = const [
    {'id': 1, 'number': 'Room 101', 'isPaid': false},
    {'id': 2, 'number': 'Room 102', 'isPaid': true},
    {'id': 3, 'number': 'Room 201', 'isPaid': false},
    {'id': 4, 'number': 'Room 202', 'isPaid': true},
    {'id': 5, 'number': 'Room 301', 'isPaid': false},
    {'id': 6, 'number': 'Room 302', 'isPaid': true},
    {'id': 7, 'number': 'Room 401', 'isPaid': false},
    {'id': 8, 'number': 'Room 402', 'isPaid': true},
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
            'Room Service Status',
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
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                final room = _rooms[index];
                final isPaid = room['isPaid'] as bool;

                return GestureDetector(
                  onTap: isPaid
                      ? null
                      : () => _showRoomDetails(context, theme, room),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isPaid
                            ? [Colors.green.shade100, Colors.green.shade50]
                            : [Colors.orange.shade100, Colors.orange.shade50],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isPaid
                            ? Colors.green.shade400
                            : Colors.orange.shade400,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isPaid ? Colors.green : Colors.orange)
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
                                : Colors.orange.shade600,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isPaid ? Colors.green : Colors.orange)
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            isPaid
                                ? Icons.check_circle_rounded
                                : Icons.hotel_rounded,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          room['number'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isPaid
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
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
                                : Colors.orange.shade600,
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

  void _showRoomDetails(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> room,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.hotel_rounded,
              color: Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(room['number']),
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
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
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
                            color: Colors.orange.shade700,
                          ),
                        ),
                        Text(
                          'Unpaid',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
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
