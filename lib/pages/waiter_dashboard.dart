import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/database_data_provider.dart';
import '../providers/auth_provider.dart';
import '../models/suspend_order.dart';
import '../services/api_service.dart';
import '../widgets/header_widget.dart';
import '../widgets/order_table_widget.dart';
import '../widgets/menu_toggle_widget.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/breadcrumb_widget.dart';
import '../widgets/content_widget.dart';
import '../widgets/orders_view_widget.dart';
import '../widgets/room_service_view_widget.dart';
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
    // Load database data when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final databaseProvider = context.read<DatabaseDataProvider>();

      // Load all data
      await databaseProvider.loadAllData();

      // Also load menu data for compatibility
      context.read<MenuProvider>().loadMenuData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartProvider>();

    return Scaffold(
      floatingActionButton: cart.isEmpty || cart.serviceType == null
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

              // Menu/Orders Toggle (hide for takeaway)
              if (cart.serviceType?.name != 'takeaway')
                MenuToggleWidget(
                  isMenuMode: _isMenuMode,
                  onToggle: (isMenu) => setState(() => _isMenuMode = isMenu),
                  isRoomService: cart.serviceType?.name == 'roomService',
                ),

              const SizedBox(height: 4),

              // Search Bar (show in menu mode or takeaway)
              if (_isMenuMode || cart.serviceType?.name == 'takeaway')
                const SearchBarWidget(),

              const SizedBox(height: 2),

              // Breadcrumb (show in menu mode or takeaway)
              if (_isMenuMode || cart.serviceType?.name == 'takeaway')
                const BreadcrumbWidget(),

              const SizedBox(height: 2),

              // Content Section
              Expanded(
                child: _isMenuMode || cart.serviceType?.name == 'takeaway'
                    ? const ContentWidget()
                    : cart.serviceType?.name == 'roomService'
                    ? const RoomServiceViewWidget()
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
    final remarksController = TextEditingController();
    List<Map<String, dynamic>> tables = [];
    List<Map<String, dynamic>> chairs = [];
    List<Map<String, dynamic>> rooms = [];
    String? selectedTable;
    String? selectedChair;
    String? selectedRoom;
    bool isLoadingTables = true;
    bool isLoadingChairs = false;
    bool isLoadingRooms = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Load data based on service type
          if (cart.serviceType?.name == 'roomService') {
            // Load rooms for room service
            if (isLoadingRooms && rooms.isEmpty) {
              ApiService.getRooms()
                  .then((loadedRooms) {
                    if (context.mounted) {
                      setState(() {
                        rooms = loadedRooms;
                        isLoadingRooms = false;
                      });
                    }
                  })
                  .catchError((error) {
                    if (context.mounted) {
                      setState(() {
                        isLoadingRooms = false;
                      });
                      print('Error loading rooms: $error');
                    }
                  });
            }
          } else {
            // Load tables and chairs for dine-in/takeaway
            if (isLoadingTables && tables.isEmpty) {
              // Load tables from inv_tables
              ApiService.getTables()
                  .then((loadedTables) {
                    if (context.mounted) {
                      setState(() {
                        tables = loadedTables;
                        isLoadingTables = false;
                      });
                    }
                  })
                  .catchError((error) {
                    if (context.mounted) {
                      setState(() {
                        isLoadingTables = false;
                      });
                      print('Error loading tables: $error');
                    }
                  });

              // Load chairs independently
              ApiService.getChairs()
                  .then((loadedChairs) {
                    if (context.mounted) {
                      setState(() {
                        chairs = loadedChairs;
                        isLoadingChairs = false;
                      });
                    }
                  })
                  .catchError((error) {
                    if (context.mounted) {
                      setState(() {
                        isLoadingChairs = false;
                      });
                      print('Error loading chairs: $error');
                    }
                  });
            }
          }

          return AlertDialog(
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
              width: 320,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 500),
                child: SingleChildScrollView(
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
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.7),
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
                      // Conditional Selection based on Service Type
                      if (cart.serviceType?.name == 'roomService') ...[
                        // Room Selection Dropdown for Room Service
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: isLoadingRooms
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Loading rooms...'),
                                    ],
                                  ),
                                )
                              : DropdownButtonFormField<String>(
                                  value: selectedRoom,
                                  decoration: InputDecoration(
                                    labelText: 'Room *',
                                    prefixIcon: Icon(
                                      Icons.bed,
                                      color: theme.colorScheme.primary,
                                      size: 18,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    labelStyle: const TextStyle(fontSize: 14),
                                  ),
                                  hint: const Text(
                                    'Select room',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  items: rooms.map((room) {
                                    return DropdownMenuItem<String>(
                                      value: room['RoomCode'],
                                      child: Text(
                                        '${room['RoomCode']} - ${room['RoomName']}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedRoom = newValue;
                                    });
                                  },
                                ),
                        ),
                      ] else ...[
                        // Table Selection for Dine-in/Takeaway
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: isLoadingTables
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Loading tables...'),
                                    ],
                                  ),
                                )
                              : DropdownButtonFormField<String>(
                                  value: selectedTable,
                                  decoration: InputDecoration(
                                    labelText: 'Table *',
                                    prefixIcon: Icon(
                                      Icons.table_restaurant,
                                      color: theme.colorScheme.primary,
                                      size: 18,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    labelStyle: const TextStyle(fontSize: 14),
                                  ),
                                  hint: const Text(
                                    'Select table',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  items: tables.map((table) {
                                    return DropdownMenuItem<String>(
                                      value: table['TableCode'],
                                      child: Text(
                                        '${table['TableCode']} - ${table['TableName']}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedTable = newValue;
                                      selectedChair =
                                          null; // Reset chair selection when table changes
                                    });
                                  },
                                ),
                        ),
                        const SizedBox(height: 16),
                        // Chair Selection for Dine-in/Takeaway
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: isLoadingChairs
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Loading chairs...'),
                                    ],
                                  ),
                                )
                              : DropdownButtonFormField<String>(
                                  value: selectedChair,
                                  decoration: InputDecoration(
                                    labelText: 'Chair *',
                                    prefixIcon: Icon(
                                      Icons.chair_rounded,
                                      color: theme.colorScheme.primary,
                                      size: 18,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    labelStyle: const TextStyle(fontSize: 14),
                                  ),
                                  hint: const Text(
                                    'Select chair',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  items: chairs
                                      .where(
                                        (chair) =>
                                            chair['tableCode'] == selectedTable,
                                      )
                                      .map((chair) {
                                        return DropdownMenuItem<String>(
                                          value: chair['chairCode'],
                                          child: Text(
                                            '${chair['chairCode']} - ${chair['chairName']}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        );
                                      })
                                      .toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedChair = newValue;
                                    });
                                  },
                                ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Remarks/Special Requests Input
                      TextField(
                        controller: remarksController,
                        decoration: InputDecoration(
                          labelText: 'Special Requests / Remarks',
                          hintText: 'e.g., No spice, Extra sauce',
                          prefixIcon: Icon(
                            Icons.note_rounded,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        maxLines: 2,
                        maxLength: 100,
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
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (cart.serviceType == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.warning_rounded, color: Colors.white),
                            const SizedBox(width: 8),
                            const Text('Service type selection is required!'),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                    return;
                  }

                  if (cart.serviceType?.name == 'roomService') {
                    // Validate room selection for room service
                    if (selectedRoom == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a room'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                  } else {
                    // Validate table and chair selection for dine-in/takeaway
                    if (selectedTable == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a table'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (selectedChair == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a chair'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                  }

                  Navigator.of(context).pop();

                  // Capture cart items and other data before clearing
                  final cartItems = List.from(cart.items);
                  final tableNumber = cart.serviceType?.name == 'roomService'
                      ? null
                      : selectedTable!;
                  final chairNumber = cart.serviceType?.name == 'roomService'
                      ? null
                      : selectedChair ?? '';
                  final roomNumber = cart.serviceType?.name == 'roomService'
                      ? selectedRoom!
                      : null;
                  final serviceType = cart.serviceType;
                  final customerName = cart.customerName;

                  // Clear the cart immediately
                  cart.clearCart();

                  // Show success dialog immediately
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green,
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
                            'Receipt: RCP${DateTime.now().millisecondsSinceEpoch}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Table: $tableNumber',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Chair: $chairNumber',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (serviceType != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Service: ${serviceType.displayName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );

                  // Process order in background with captured data
                  _processOrderInBackground(
                    context,
                    cartItems,
                    tableNumber ?? '',
                    chairNumber ?? '',
                    customerName,
                    roomNumber,
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
          );
        },
      ),
    );
  }

  void _processOrderInBackground(
    BuildContext context,
    List cartItems,
    String tableNumber,
    String chairNumber,
    String? customerName,
    String? roomNumber,
  ) async {
    print('🔄 Starting background order processing...');
    print('📋 Cart items count: ${cartItems.length}');
    print('🏷️ Table: $tableNumber');
    print('🪑 Chair: $chairNumber');
    print('🏨 Room: $roomNumber');
    print('👤 Customer: $customerName');

    if (cartItems.isEmpty) {
      print('❌ No cart items to process!');
      return;
    }

    try {
      final databaseData = context.read<DatabaseDataProvider>();
      final authProvider = context.read<AuthProvider>();

      print('👤 Salesman: ${authProvider.salesmanName}');
      print('🔑 Salesman Code: ${authProvider.salesmanCode}');

      // Convert cart items to suspend orders and add to database
      for (int i = 0; i < cartItems.length; i++) {
        final cartItem = cartItems[i];
        print('➕ Processing item ${i + 1}/${cartItems.length}:');
        print('   - Name: ${cartItem.foodItem.name}');
        print('   - ID: ${cartItem.foodItem.id}');
        print('   - Price: ${cartItem.foodItem.price}');
        print('   - Quantity: ${cartItem.quantity}');
        print('   - Total: ${cartItem.totalPrice}');

        // Generate unique ID using timestamp + counter
        final orderId = DateTime.now().millisecondsSinceEpoch + i;
        print('🔢 Generated Order ID: $orderId');

        final suspendOrder = SuspendOrder(
          id: orderId,
          productCode: cartItem.foodItem.id,
          productDescription: cartItem.foodItem.name,
          unit: 'piece',
          costPrice: cartItem.foodItem.price * 0.7,
          unitPrice: cartItem.foodItem.price,
          wholeSalePrice: cartItem.foodItem.price * 0.85,
          qty: cartItem.quantity.toDouble(),
          amount: cartItem.totalPrice,
          salesMan: authProvider.salesmanName.isNotEmpty
              ? authProvider.salesmanName
              : authProvider.salesmanCode,
          table:
              roomNumber ??
              tableNumber, // Use room number for room service, table number for dine-in/takeaway
          chair: roomNumber != null
              ? ''
              : chairNumber, // No chair for room service
          customer: customerName ?? 'Guest',
          kotPrint: false,
        );

        print('📦 Created SuspendOrder object:');
        print('   - ProductCode: ${suspendOrder.productCode}');
        print('   - ProductDescription: ${suspendOrder.productDescription}');
        print('   - UnitPrice: ${suspendOrder.unitPrice}');
        print('   - Qty: ${suspendOrder.qty}');
        print('   - Amount: ${suspendOrder.amount}');
        print('   - SalesMan: ${suspendOrder.salesMan}');
        print('   - Table/Room: ${suspendOrder.table}');
        print('   - Chair: ${suspendOrder.chair}');

        try {
          print('🔄 Calling databaseData.addToCart...');
          await databaseData.addToCart(suspendOrder);
          print('✅ Item ${i + 1} added successfully to database');
        } catch (itemError) {
          print('❌ Failed to add item ${i + 1}: $itemError');
          print('❌ Item error details: ${itemError.toString()}');
          // Continue with other items instead of stopping
        }
      }

      // Confirm the order
      print('🔄 Confirming order for table: $tableNumber');
      try {
        final result = await databaseData.confirmOrder(
          tableNumber,
          receiptNo: 'RCP${DateTime.now().millisecondsSinceEpoch}',
          salesMan: authProvider.salesmanName.isNotEmpty
              ? authProvider.salesmanName
              : authProvider.salesmanCode,
        );

        print('📊 Confirm order result: $result');
        if (result != null && result['success'] == true) {
          print('✅ Background order processing completed successfully');
          print('📄 Receipt: ${result['receiptNo']}');
        } else {
          print('❌ Background order confirmation failed - result: $result');
        }
      } catch (confirmError) {
        print('❌ Error confirming order: $confirmError');
        print('❌ Confirm error details: ${confirmError.toString()}');
      }
    } catch (e, stackTrace) {
      print('❌ Error in background order processing: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }
}
