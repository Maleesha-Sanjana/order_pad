import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/database_data_provider.dart';
import '../widgets/connection_status_widget.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final databaseData = context.watch<DatabaseDataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Real-time Sync Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.cloud_sync,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Real-time Data Sync',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Enable/Disable toggle
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Enable Real-time Sync',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Automatically sync data changes from the database',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: databaseData.isRealtimeEnabled,
                          onChanged: (value) {
                            databaseData.setRealtimeEnabled(value);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Detailed connection status
                    const DetailedConnectionStatusWidget(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Data Management Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.storage,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Data Management',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Data counts
                    _buildDataCountRow(
                      theme,
                      'Departments',
                      databaseData.departments.length.toString(),
                      Icons.business,
                    ),
                    const SizedBox(height: 8),
                    _buildDataCountRow(
                      theme,
                      'Menu Items',
                      databaseData.menuItems.length.toString(),
                      Icons.restaurant,
                    ),
                    const SizedBox(height: 8),
                    _buildDataCountRow(
                      theme,
                      'Pending Orders',
                      databaseData.suspendOrders.length.toString(),
                      Icons.shopping_cart,
                    ),
                    const SizedBox(height: 8),
                    _buildDataCountRow(
                      theme,
                      'Users',
                      databaseData.users.length.toString(),
                      Icons.people,
                    ),

                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await databaseData.forceRefresh();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Data refreshed successfully',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh All Data'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showClearCacheDialog(context, databaseData);
                            },
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Clear Cache'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Sync Configuration Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tune,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Sync Configuration',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildConfigRow(
                      theme,
                      'Polling Interval',
                      '30 seconds',
                      Icons.timer,
                    ),
                    const SizedBox(height: 8),
                    _buildConfigRow(
                      theme,
                      'Auto-refresh Interval',
                      '5 minutes',
                      Icons.schedule,
                    ),
                    const SizedBox(height: 8),
                    _buildConfigRow(
                      theme,
                      'Connection Timeout',
                      '10 seconds',
                      Icons.timer_off,
                    ),
                    const SizedBox(height: 8),
                    _buildConfigRow(
                      theme,
                      'WebSocket URL',
                      'ws://172.20.10.3:3000/ws',
                      Icons.link,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // About Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'About',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Waiter Order Pad v1.0.0',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Real-time database synchronization system with WebSocket and polling support.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showLogsDialog(context, databaseData);
                            },
                            icon: const Icon(Icons.description),
                            label: const Text('View Logs'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showHelpDialog(context);
                            },
                            icon: const Icon(Icons.help_outline),
                            label: const Text('Help'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCountRow(
    ThemeData theme,
    String label,
    String count,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfigRow(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showClearCacheDialog(
    BuildContext context,
    DatabaseDataProvider databaseData,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear all cached data and force a complete refresh. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await databaseData.forceRefresh();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cache cleared and data refreshed'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showLogsDialog(
    BuildContext context,
    DatabaseDataProvider databaseData,
  ) {
    final status = databaseData.getRealtimeStatus();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Status & Logs'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Real-time Sync: ${status['isEnabled'] ? 'Enabled' : 'Disabled'}',
                ),
                Text('Connected: ${status['isConnected'] ? 'Yes' : 'No'}'),
                Text(
                  'WebSocket: ${status['isWebSocketConnected'] ? 'Active' : 'Inactive'}',
                ),
                Text('Polling: ${status['isPolling'] ? 'Active' : 'Inactive'}'),
                const SizedBox(height: 16),
                const Text(
                  'Last Update Times:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...(status['syncStatus']['lastUpdateTimes']
                        as Map<String, dynamic>)
                    .entries
                    .map(
                      (entry) =>
                          Text('${entry.key}: ${entry.value ?? 'Never'}'),
                    ),
                const SizedBox(height: 16),
                const Text(
                  'Registered Callbacks:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...(status['syncStatus']['registeredCallbacks'] as List).map(
                  (callback) => Text('• $callback'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Real-time Sync Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Real-time Data Synchronization',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'The app automatically syncs data changes from the database in real-time using:',
              ),
              SizedBox(height: 8),
              Text('• WebSocket connection for instant updates'),
              Text('• Polling as fallback every 30 seconds'),
              Text('• Auto-refresh every 5 minutes'),
              SizedBox(height: 16),
              Text(
                'Connection Status:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('🟢 Live: WebSocket connected'),
              Text('🟠 Polling: Using HTTP polling'),
              Text('🔴 Offline: No connection'),
              SizedBox(height: 16),
              Text(
                'You can manually refresh data or disable real-time sync if needed.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
