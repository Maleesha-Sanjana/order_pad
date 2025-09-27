import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/food_item.dart';

class FoodItemCardWidget extends StatelessWidget {
  final FoodItem foodItem;

  const FoodItemCardWidget({
    super.key,
    required this.foodItem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartProvider>();
    final isInCart = cart.isItemInCart(foodItem);
    final quantity = cart.getItemQuantity(foodItem);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        padding: const EdgeInsets.all(16),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        foodItem.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 8),
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
