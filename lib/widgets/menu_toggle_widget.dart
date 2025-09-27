import 'package:flutter/material.dart';

class MenuToggleWidget extends StatelessWidget {
  final bool isMenuMode;
  final ValueChanged<bool> onToggle;
  final bool isRoomService;

  const MenuToggleWidget({
    super.key,
    required this.isMenuMode,
    required this.onToggle,
    this.isRoomService = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => onToggle(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isMenuMode
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                foregroundColor: isMenuMode
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                elevation: isMenuMode ? 4 : 1,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu_rounded, size: 18),
                  const SizedBox(width: 8),
                  const Text('Menu'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => onToggle(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: !isMenuMode
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                foregroundColor: !isMenuMode
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                elevation: !isMenuMode ? 4 : 1,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isRoomService 
                        ? Icons.hotel_rounded 
                        : Icons.table_restaurant_rounded, 
                    size: 18
                  ),
                  const SizedBox(width: 8),
                  Text(isRoomService ? 'Room Service' : 'Orders'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
