import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class OrderTableWidget extends StatelessWidget {
  final VoidCallback onShowFullscreenTable;
  final VoidCallback onShowServiceTypeDialog;

  const OrderTableWidget({
    super.key,
    required this.onShowFullscreenTable,
    required this.onShowServiceTypeDialog,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.35, // 35% of screen height
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
                // Service Type Button and Clear All Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Service Type Selection Button
                    TextButton.icon(
                      onPressed: onShowServiceTypeDialog,
                      icon: Icon(
                        cart.serviceType != null
                            ? Icons.restaurant_rounded
                            : Icons.warning_rounded,
                        size: 18,
                        color: cart.serviceType != null
                            ? theme.colorScheme.primary
                            : Colors.orange,
                      ),
                      label: Text(
                        cart.serviceType?.displayName ?? 'Select Service Type',
                        style: TextStyle(
                          color: cart.serviceType != null
                              ? theme.colorScheme.primary
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: cart.serviceType != null
                            ? theme.colorScheme.primary.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    // Clear All Button
                    if (!cart.isEmpty)
                      IconButton(
                        onPressed: () =>
                            _showClearAllDialog(context, theme, cart),
                        icon: Icon(
                          Icons.clear_all_rounded,
                          size: 20,
                          color: theme.colorScheme.error,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.error.withOpacity(
                            0.1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                          minimumSize: const Size(40, 40),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        tooltip: 'Clear All Items',
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Table Headers
                Row(
                  children: [
                    Expanded(flex: 1, child: _buildTableHeader('#')),
                    Expanded(flex: 2, child: _buildTableHeader('Item')),
                    Expanded(flex: 1, child: _buildTableHeader('Pri.')),
                    Expanded(flex: 1, child: _buildTableHeader('Qty')),
                    Expanded(flex: 1, child: _buildTableHeader('Dis')),
                    Expanded(flex: 1, child: _buildTableHeader('Tot')),
                    Expanded(flex: 1, child: _buildTableHeader('Del')),
                  ],
                ),
              ],
            ),
          ),
          // Table Body
          Expanded(
            child: cart.isEmpty
                ? _buildEmptyState(theme)
                : _buildTableBody(theme, cart),
          ),
          // Total Row
          if (!cart.isEmpty) _buildTotalRow(theme, cart),
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

  Widget _buildEmptyState(ThemeData theme) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                cart.serviceType == null
                    ? Icons.warning_rounded
                    : Icons.shopping_cart_outlined,
                size: 48,
                color: cart.serviceType == null
                    ? Colors.orange.withOpacity(0.7)
                    : theme.colorScheme.outline.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                cart.serviceType == null
                    ? 'Please select a service type first'
                    : 'No items added yet',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cart.serviceType == null
                      ? Colors.orange.withOpacity(0.8)
                      : theme.colorScheme.outline.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                cart.serviceType == null
                    ? 'Click "Select Service Type" above to continue'
                    : 'Add items from the menu below',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cart.serviceType == null
                      ? Colors.orange.withOpacity(0.6)
                      : theme.colorScheme.outline.withOpacity(0.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableBody(ThemeData theme, CartProvider cart) {
    return ListView.builder(
      itemCount: cart.items.length,
      itemBuilder: (context, index) {
        final item = cart.items[index];
        final isExisting =
            item.isExisting; // Check if this is an existing order

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            // Different background for existing items
            color: isExisting
                ? theme.colorScheme.surfaceVariant.withOpacity(0.3)
                : null,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),
              left: isExisting
                  ? BorderSide(color: Colors.blue, width: 3)
                  : BorderSide.none,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isExisting)
                      Icon(Icons.lock_outline, size: 12, color: Colors.blue),
                    if (isExisting) const SizedBox(width: 4),
                    Text(
                      '${index + 1}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: isExisting ? Colors.blue : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  item.foodItem.name,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 11,
                    color: isExisting ? Colors.blue.shade700 : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${item.foodItem.price.toStringAsFixed(0)}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    color: isExisting ? Colors.blue : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${item.quantity}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: isExisting ? Colors.blue : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '0%',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: isExisting ? Colors.blue : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${item.totalPrice.toStringAsFixed(0)}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    color: isExisting ? Colors.blue : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: isExisting
                    ? Icon(Icons.check_circle, color: Colors.blue, size: 20)
                    : IconButton(
                        onPressed: () {
                          cart.removeItemByIndex(index);
                        },
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: theme.colorScheme.error,
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.error.withOpacity(
                            0.1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalRow(ThemeData theme, CartProvider cart) {
    return Container(
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
    );
  }

  void _showClearAllDialog(
    BuildContext context,
    ThemeData theme,
    CartProvider cart,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All Items'),
        content: const Text(
          'Are you sure you want to remove all items from the order?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              cart.clearCart();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
