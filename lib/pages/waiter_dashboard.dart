import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/database_data_provider.dart';
import '../providers/auth_provider.dart';
import '../models/suspend_order.dart';
import '../models/cart_item.dart';
import '../models/service_type.dart';
import '../services/api_service.dart';
import '../widgets/header_widget.dart';
import '../widgets/order_table_widget.dart';
import '../widgets/menu_toggle_widget.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/breadcrumb_widget.dart';
import '../widgets/content_widget.dart';
import '../widgets/orders_view_widget.dart';
import '../widgets/room_service_view_widget.dart';
import '../widgets/takeaway_view_widget.dart';
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

  String _getServiceTypeName(String? serviceType) {
    switch (serviceType) {
      case 'takeaway':
        return 'Takeaway';
      case 'dineIn':
        return 'DineIn';
      case 'roomService':
        return 'RoomService';
      default:
        return 'Orders';
    }
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

              // Menu/Orders Toggle (show for all service types)
              if (cart.serviceType != null)
                MenuToggleWidget(
                  isMenuMode: _isMenuMode,
                  onToggle: (isMenu) {
                    setState(() => _isMenuMode = isMenu);
                    // Auto-refresh unpaid orders when switching to unpaid view
                    if (!isMenu) {
                      final databaseData = context.read<DatabaseDataProvider>();
                      databaseData.loadSuspendOrders();
                      print('🔄 Auto-refreshing unpaid orders on toggle');
                    }
                  },
                  serviceTypeName: _getServiceTypeName(cart.serviceType?.name),
                ),

              const SizedBox(height: 4),

              // Search Bar (show in menu mode)
              if (_isMenuMode) const SearchBarWidget(),

              const SizedBox(height: 2),

              // Breadcrumb (show in menu mode)
              if (_isMenuMode) const BreadcrumbWidget(),

              const SizedBox(height: 2),

              // Content Section
              Expanded(
                child: _isMenuMode
                    ? const ContentWidget()
                    : cart.serviceType?.name == 'roomService'
                    ? const RoomServiceViewWidget()
                    : cart.serviceType?.name == 'takeaway'
                    ? const TakeawayViewWidget()
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

    // Pre-populate with existing values if adding to an existing order
    String? selectedTable = cart.tableNumber;
    String? selectedChair;
    String? selectedRoom = cart.serviceType?.name == 'roomService'
        ? cart.tableNumber
        : null;
    String? previousTable; // Track previous value
    String? previousRoom; // Track previous value
    bool isLoadingTables = true;
    bool isLoadingChairs = false;
    bool isLoadingRooms = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Check if adding to existing order (before using it)
          final isAddingToExistingOrder = cart.existingItemsCount > 0;

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
                      // Banner for adding to existing order
                      if (isAddingToExistingOrder) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.shade300,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: Colors.green.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Adding to Existing Order',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                    Text(
                                      '${cart.existingItemsCount} existing items in cart',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green.shade700,
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
                      Text(
                        isAddingToExistingOrder
                            ? 'Only new items will be sent to kitchen:'
                            : 'Please provide the following details to complete the order:',
                        style: const TextStyle(fontSize: 14),
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
                              : isAddingToExistingOrder
                              // Show disabled field with existing room when adding to existing order
                              ? Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.bed,
                                        color: Colors.grey.shade600,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Room: $selectedRoom (Locked)',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.lock,
                                        color: Colors.grey.shade500,
                                        size: 16,
                                      ),
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
                                    final bool isOccupied =
                                        room['isOccupied'] == true;
                                    final String displayText =
                                        '${room['RoomCode']} - ${room['RoomName']}${isOccupied ? ' (OCCUPIED)' : ''}';
                                    return DropdownMenuItem<String>(
                                      value: room['RoomCode'],
                                      child: Text(
                                        displayText,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isOccupied
                                              ? Colors.red.shade400
                                              : Colors.black,
                                          fontWeight: isOccupied
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue == null) return;

                                    // Check if selected room is occupied
                                    final selectedRoomData = rooms.firstWhere(
                                      (room) => room['RoomCode'] == newValue,
                                      orElse: () => {},
                                    );

                                    if (selectedRoomData.isNotEmpty &&
                                        selectedRoomData['isOccupied'] ==
                                            true) {
                                      // Show warning dialog - DO NOT update selection
                                      showDialog(
                                        context: context,
                                        builder: (dialogContext) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          title: Row(
                                            children: [
                                              Icon(
                                                Icons.block_rounded,
                                                color: Colors.red.shade700,
                                                size: 32,
                                              ),
                                              const SizedBox(width: 12),
                                              const Expanded(
                                                child: Text(
                                                  'Room Occupied!',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Room ${selectedRoomData['RoomCode']} - ${selectedRoomData['RoomName']} has an unpaid order.',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color:
                                                        Colors.orange.shade200,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.info_outline,
                                                      color: Colors
                                                          .orange
                                                          .shade700,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Expanded(
                                                      child: Text(
                                                        'Please select a different room or complete the existing order first.',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () => Navigator.of(
                                                dialogContext,
                                              ).pop(),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    theme.colorScheme.primary,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 12,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text(
                                                'OK, I\'ll Choose Another',
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      // Reset to previous value after dialog closes
                                      Future.delayed(
                                        const Duration(milliseconds: 100),
                                        () {
                                          setState(() {
                                            selectedRoom =
                                                previousRoom; // Restore previous value
                                          });
                                        },
                                      );
                                      return;
                                    }

                                    // Room is available, update selection
                                    setState(() {
                                      previousRoom =
                                          selectedRoom; // Save current value before updating
                                      selectedRoom = newValue;
                                    });
                                  },
                                ),
                        ),
                      ] else ...[
                        // Table Selection for Dine-in and Takeaway
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
                              : isAddingToExistingOrder
                              // Show disabled field with existing table when adding to existing order
                              ? Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.table_restaurant,
                                        color: Colors.grey.shade600,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Table: $selectedTable (Locked)',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.lock,
                                        color: Colors.grey.shade500,
                                        size: 16,
                                      ),
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
                                    final bool isOccupied =
                                        table['isOccupied'] == true;
                                    final String displayText =
                                        '${table['TableCode']} - ${table['TableName']}${isOccupied ? ' (OCCUPIED)' : ''}';
                                    return DropdownMenuItem<String>(
                                      value: table['TableCode'],
                                      child: Text(
                                        displayText,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isOccupied
                                              ? Colors.red.shade400
                                              : Colors.black,
                                          fontWeight: isOccupied
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue == null) return;

                                    // Check if selected table is occupied
                                    final selectedTableData = tables.firstWhere(
                                      (table) => table['TableCode'] == newValue,
                                      orElse: () => {},
                                    );

                                    if (selectedTableData.isNotEmpty &&
                                        selectedTableData['isOccupied'] ==
                                            true) {
                                      // Show warning dialog - DO NOT update selection
                                      showDialog(
                                        context: context,
                                        builder: (dialogContext) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          title: Row(
                                            children: [
                                              Icon(
                                                Icons.block_rounded,
                                                color: Colors.red.shade700,
                                                size: 32,
                                              ),
                                              const SizedBox(width: 12),
                                              const Expanded(
                                                child: Text(
                                                  'Table Occupied!',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Table ${selectedTableData['TableCode']} - ${selectedTableData['TableName']} has an unpaid order.',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color:
                                                        Colors.orange.shade200,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.info_outline,
                                                      color: Colors
                                                          .orange
                                                          .shade700,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Expanded(
                                                      child: Text(
                                                        'Please select a different table or complete the existing order first.',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () => Navigator.of(
                                                dialogContext,
                                              ).pop(),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    theme.colorScheme.primary,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 12,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text(
                                                'OK, I\'ll Choose Another',
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      // Reset to previous value after dialog closes
                                      Future.delayed(
                                        const Duration(milliseconds: 100),
                                        () {
                                          setState(() {
                                            selectedTable =
                                                previousTable; // Restore previous value
                                          });
                                        },
                                      );
                                      return;
                                    }

                                    // Table is available, update selection
                                    setState(() {
                                      previousTable =
                                          selectedTable; // Save current value before updating
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

                    // Only check if room is occupied when creating NEW order (not adding to existing)
                    if (!isAddingToExistingOrder) {
                      final selectedRoomData = rooms.firstWhere(
                        (room) => room['RoomCode'] == selectedRoom,
                        orElse: () => {},
                      );
                      if (selectedRoomData.isNotEmpty &&
                          selectedRoomData['isOccupied'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.block_rounded, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Room ${selectedRoomData['RoomCode']} is occupied with an unpaid order! Please select a different room.',
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.red.shade700,
                            duration: const Duration(seconds: 4),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                        return;
                      }
                    }
                  } else {
                    // Validate table and chair selection for dine-in and takeaway
                    if (selectedTable == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a table'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Only check if table is occupied when creating NEW order (not adding to existing)
                    // Skip occupied check for takeaway orders
                    if (!isAddingToExistingOrder &&
                        cart.serviceType?.name != 'takeaway') {
                      final selectedTableData = tables.firstWhere(
                        (table) => table['TableCode'] == selectedTable,
                        orElse: () => {},
                      );
                      if (selectedTableData.isNotEmpty &&
                          selectedTableData['isOccupied'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.block_rounded, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Table ${selectedTableData['TableCode']} is occupied with an unpaid order! Please select a different table.',
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.red.shade700,
                            duration: const Duration(seconds: 4),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                        return;
                      }
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

                  // Capture only NEW items (skip existing items)
                  final cartItems = cart.existingItemsCount > 0
                      ? List.from(cart.newItems) // Only new items
                      : List.from(cart.items); // All items if new order
                  final isAddingToExisting = cart.existingItemsCount > 0;
                  final existingItemsCount = cart.existingItemsCount;
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

                  // Use existing receipt number if adding to an existing order
                  String receiptNumber = '100000001'; // Default fallback
                  String? unitPart;
                  String? counterPart;

                  if (cart.existingReceiptNo != null &&
                      cart.existingReceiptNo!.isNotEmpty) {
                    receiptNumber = cart.existingReceiptNo!;
                    print(
                      '🔄 Using existing receipt number for adding items: $receiptNumber',
                    );
                    print(
                      '📋 Existing items in cart: ${cart.existingItemsCount}',
                    );
                    print('📋 Total items in cart: ${cart.items.length}');
                    print('📋 NEW items to send: ${cartItems.length}');
                    print(
                      '⚠️ Will NOT increment sysconfig.ReceiptNo (reusing existing receipt)',
                    );
                  } else {
                    // Generate new receipt number from sysconfig (combines Unit + ReceiptNo)
                    try {
                      print('🔄 Calling generateReceiptNumber API...');
                      final receiptResult =
                          await ApiService.generateReceiptNumber('temp');
                      print('📊 Receipt API response: $receiptResult');
                      print('📊 Response type: ${receiptResult.runtimeType}');
                      print(
                        '📊 Receipt No from API: ${receiptResult['receiptNo']}',
                      );
                      print('📊 Unit from API: ${receiptResult['unit']}');
                      print('📊 Counter from API: ${receiptResult['counter']}');

                      if (receiptResult['success'] == true &&
                          receiptResult['receiptNo'] != null) {
                        receiptNumber = receiptResult['receiptNo'].toString();
                        unitPart = receiptResult['unit']?.toString();
                        counterPart = receiptResult['counter']?.toString();
                        print(
                          '✅ Using receipt number from API: $receiptNumber',
                        );
                        print(
                          '✅ This combines sysconfig.Unit ($unitPart) + sysconfig.ReceiptNo ($counterPart)',
                        );
                      } else {
                        print(
                          '⚠️ API returned success=false or null receiptNo',
                        );
                        print('⚠️ Full response: $receiptResult');
                        print('⚠️ Using default fallback: $receiptNumber');
                      }
                    } catch (e) {
                      print('❌ Error generating receipt number: $e');
                      print('❌ Error type: ${e.runtimeType}');
                      print('❌ Error details: ${e.toString()}');
                      print(
                        '❌ Using default fallback receipt number: $receiptNumber',
                      );
                    }
                  }

                  // Clear the cart immediately
                  cart.clearCart();

                  // Show success dialog immediately with generated receipt number
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
                          Text(
                            isAddingToExisting
                                ? '$existingItemsCount existing items + ${cartItems.length} new items sent to kitchen!'
                                : 'Your order has been sent to the kitchen successfully.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.3,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Receipt Number',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  receiptNumber,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                    letterSpacing: 2,
                                  ),
                                ),
                                if (unitPart != null &&
                                    counterPart != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Unit: $unitPart | Counter: $counterPart',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (tableNumber != null) ...[
                            Text(
                              'Table: $tableNumber',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (chairNumber != null && chairNumber.isNotEmpty)
                              Text(
                                'Chair: $chairNumber',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                          if (roomNumber != null) ...[
                            Text(
                              'Room: $roomNumber',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
                    receiptNumber,
                    serviceType, // Pass service type to background processing
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
    String receiptNumber,
    ServiceType? serviceType, // Add service type parameter
  ) async {
    print('🔄 Starting background order processing...');
    print('📋 Cart items to send (NEW ITEMS ONLY): ${cartItems.length}');
    print('🏷️ Table/Room: ${roomNumber ?? tableNumber}');
    print('🪑 Chair: $chairNumber');
    print('👤 Customer: $customerName');
    print('🧾 Receipt Number: $receiptNumber');
    print(
      '🖨️ KotPrint Status: All ${cartItems.length} items will have KotPrint=1 (NEW ITEMS for kitchen)',
    );

    if (cartItems.isEmpty) {
      print('❌ No cart items to process!');
      return;
    }

    try {
      final databaseData = context.read<DatabaseDataProvider>();
      final authProvider = context.read<AuthProvider>();
      final cartProvider = context.read<CartProvider>();

      print('👤 Salesman: ${authProvider.salesmanName}');
      print('🔑 Salesman Code: ${authProvider.salesmanCode}');

      // Check if table has existing items and get max ID + receipt number
      final tableOrRoom = roomNumber ?? tableNumber;

      // Check if this is adding to existing order or new order
      final existingItemsCount = cartProvider.existingItemsCount;
      final isAddingToExistingOrder = existingItemsCount > 0;

      print('📊 Total items in cart: ${cartItems.length}');
      print('📊 Existing items count: $existingItemsCount');
      print('📊 Is adding to existing order: $isAddingToExistingOrder');

      int startingId = 1;
      String? existingReceiptNo = cartProvider.existingReceiptNo;
      List<CartItem> itemsToSave;

      if (isAddingToExistingOrder) {
        // Adding to existing order - only save NEW items
        itemsToSave = cartProvider.newItems;
        print('📊 EXISTING ORDER MODE:');
        print('   - Total items in cart: ${cartItems.length}');
        print('   - Existing items count: ${cartProvider.existingItemsCount}');
        print('   - NEW items to save: ${itemsToSave.length}');
        print('   - Existing ReceiptNo: ${cartProvider.existingReceiptNo}');

        if (itemsToSave.isEmpty) {
          print('⚠️ No new items to save - only existing items in cart');
          return;
        }

        // Debug: Show what we're about to save
        for (int i = 0; i < itemsToSave.length; i++) {
          print(
            '   NEW Item ${i + 1}: ${itemsToSave[i].foodItem.name} x${itemsToSave[i].quantity}',
          );
        }
      } else {
        // New order - save ALL items
        itemsToSave = cartItems.cast<CartItem>();
        print('📊 NEW ORDER MODE:');
        print('   - ALL items to save: ${itemsToSave.length}');
      }

      try {
        final existingItems = await ApiService.getSuspendOrdersByTable(
          tableOrRoom,
        );
        if (existingItems.isNotEmpty) {
          // Get max ID from database to continue sequence
          final maxId = existingItems
              .map((item) => item.id ?? 0)
              .reduce((a, b) => a > b ? a : b);
          startingId = maxId + 1;

          // Get receipt number from existing items
          if (existingReceiptNo == null &&
              existingItems.first.receiptNo != null) {
            existingReceiptNo = existingItems.first.receiptNo;
          }

          print('📋 DATABASE CHECK:');
          print('   - Existing items in database: ${existingItems.length}');
          print('   - Max ID in database: $maxId');
          print('   - NEW items will start from ID: $startingId');
          if (existingReceiptNo != null) {
            print('   - Using existing ReceiptNo: $existingReceiptNo');
          }

          // Debug: Show existing items
          print('   - Existing items in DB:');
          for (var item in existingItems) {
            print(
              '     ID=${item.id}, Product=${item.productDescription}, Qty=${item.qty}',
            );
          }
        } else {
          print('✅ New order - IDs will start from: 1');
        }
      } catch (e) {
        print('⚠️ Could not fetch existing items: $e');
      }

      // Convert cart items to suspend orders and add to database
      for (int i = 0; i < itemsToSave.length; i++) {
        final cartItem = itemsToSave[i];
        print('➕ Processing item ${i + 1}/${itemsToSave.length}:');
        print('   - Name: ${cartItem.foodItem.name}');
        print('   - ID: ${cartItem.foodItem.id}');
        print('   - Price: ${cartItem.foodItem.price}');
        print('   - Quantity: ${cartItem.quantity}');
        print('   - Total: ${cartItem.totalPrice}');

        // Use sequential ID continuing from database max ID
        final orderId = startingId + i;
        print('🔢 Database ID: $orderId (KotPrint=1 for NEW items)');

        // Determine batch number based on service type
        String batchNumber;
        if (roomNumber != null) {
          batchNumber = 'RoomService';
        } else if (serviceType?.name == 'takeaway') {
          batchNumber = 'Takeaway';
        } else {
          batchNumber = 'DineIn';
        }

        // Debug logging
        print('🔍 Service Type Debug:');
        print('   - roomNumber: $roomNumber');
        print('   - serviceType?.name: ${serviceType?.name}');
        print('   - Final batchNumber: $batchNumber');

        final suspendOrder = SuspendOrder(
          id: orderId,
          productCode: cartItem.foodItem.id,
          productDescription: cartItem.foodItem.name,
          unit:
              '1', // Unit used as prefix for receipt number (e.g., "1" + "0000001" = "10000001")
          costPrice: cartItem.foodItem.price * 0.7,
          unitPrice: cartItem.foodItem.price,
          wholeSalePrice: cartItem.foodItem.price * 0.85,
          qty: cartItem.quantity.toDouble(),
          amount: cartItem.totalPrice,
          batchNo:
              batchNumber, // Set based on service type: RoomService, Takeaway, or DineIn
          receiptNo:
              existingReceiptNo, // Use existing receipt number if adding to table
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
          kotPrint: true,
        );

        print('📦 Created SuspendOrder object:');
        print('   - ID: ${suspendOrder.id}');
        print('   - ProductCode: ${suspendOrder.productCode}');
        print('   - ProductDescription: ${suspendOrder.productDescription}');
        print('   - UnitPrice: ${suspendOrder.unitPrice}');
        print('   - Qty: ${suspendOrder.qty}');
        print('   - Amount: ${suspendOrder.amount}');
        print('   - BatchNo: ${suspendOrder.batchNo}');
        print(
          '   - ReceiptNo: ${suspendOrder.receiptNo ?? "NULL (will be assigned)"}',
        );
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

      // Confirm the order (skip if already has ReceiptNo)
      if (existingReceiptNo != null) {
        print('✅ Order already has ReceiptNo: $existingReceiptNo');
        print('✅ Skipping confirmation - just added items to existing receipt');
      } else {
        // Use room number for room service, table number for dine-in/takeaway
        final tableOrRoom = roomNumber ?? tableNumber;
        print('🔄 Confirming order for table/room: $tableOrRoom');
        print('📋 Using receipt number: $receiptNumber');
        try {
          final result = await databaseData.confirmOrder(
            tableOrRoom,
            receiptNo: receiptNumber,
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
      }
    } catch (e, stackTrace) {
      print('❌ Error in background order processing: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }
}
