import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/header_widget.dart';
import '../widgets/order_table_widget.dart';
import '../widgets/menu_toggle_widget.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/breadcrumb_widget.dart';
import '../widgets/content_widget.dart';
import '../widgets/orders_view_widget.dart';
import '../widgets/service_type_dialog.dart';

class WaiterDashboard extends StatefulWidget {
  const WaiterDashboard({super.key});

  @override
  State<WaiterDashboard> createState() => _WaiterDashboardState();
}

class _WaiterDashboardState extends State<WaiterDashboard> {
  bool _isMenuMode = true; // true for menu, false for orders

  @override
  void initState() {
    super.initState();
    // Load menu data when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().loadMenuData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartProvider>();

    return Scaffold(
      floatingActionButton: cart.isEmpty
          ? null
          : Container(
              margin: const EdgeInsets.all(16),
              child: FloatingActionButton.extended(
                onPressed: () => _showFullscreenTable(context, cart, theme),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                icon: const Icon(Icons.check_rounded),
                label: const Text(
                  'Confirm Order',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.surface,
              theme.colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              const HeaderWidget(),

              // Order Table
              OrderTableWidget(
                onShowFullscreenTable: () =>
                    _showFullscreenTable(context, cart, theme),
                onShowServiceTypeDialog: () => ServiceTypeDialog.show(context),
              ),

              const SizedBox(height: 8),

              // Menu/Orders Toggle
              MenuToggleWidget(
                isMenuMode: _isMenuMode,
                onToggle: (isMenu) => setState(() => _isMenuMode = isMenu),
              ),

              const SizedBox(height: 8),

              // Search Bar (only show in menu mode)
              if (_isMenuMode) const SearchBarWidget(),

              const SizedBox(height: 4),

              // Breadcrumb (only show in menu mode)
              if (_isMenuMode) const BreadcrumbWidget(),

              const SizedBox(height: 4),

              // Content Section
              Expanded(
                child: _isMenuMode
                    ? const ContentWidget()
                    : const OrdersViewWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullscreenTable(
    BuildContext context,
    CartProvider cart,
    ThemeData theme,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Summary',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close_rounded,
                            color: theme.colorScheme.outline,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.outline
                                .withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Table
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: OrderTableWidget(
                        onShowFullscreenTable: () {},
                        onShowServiceTypeDialog: () {},
                      ),
                    ),
                  ),
                  // Action Buttons
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.outline
                                  .withOpacity(0.1),
                              foregroundColor: theme.colorScheme.outline,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text('Continue Shopping'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showOrderConfirmation(context, theme, cart);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text('Confirm Order'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        );
      },
    );
  }

  void _showOrderConfirmation(
    BuildContext context,
    ThemeData theme,
    CartProvider cart,
  ) {
    final seatController = TextEditingController();
    final remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.restaurant_rounded,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text('Order Details'),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Please provide the following details to complete the order:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                // Service Type Display
                if (cart.serviceType != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              cart.serviceType!.icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Service Type',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.7,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                cart.serviceType!.displayName,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Seat Number Input
                TextField(
                  controller: seatController,
                  decoration: InputDecoration(
                    labelText: 'Seat Number *',
                    hintText: 'e.g., Table 5, Seat 2',
                    prefixIcon: Icon(
                      Icons.chair_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                // Remarks/Special Requests Input
                TextField(
                  controller: remarksController,
                  decoration: InputDecoration(
                    labelText: 'Special Requests / Remarks',
                    hintText: 'e.g., No spice, Extra sauce, etc.',
                    prefixIcon: Icon(
                      Icons.note_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 16),
                // Order Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Rs.${cart.total.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: theme.colorScheme.primary,
                        ),
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (cart.serviceType == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a service type first'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (seatController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter seat number'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop();

                // Show success dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Text('Order Confirmed!'),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Your order has been sent to the kitchen successfully.',
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Seat: ${seatController.text.trim()}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (cart.serviceType != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Service: ${cart.serviceType!.displayName}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                        if (remarksController.text.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Remarks: ${remarksController.text.trim()}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          cart.clearCart();
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Confirm Order'),
            ),
          ],
        ),
      ),
    );
  }
}
