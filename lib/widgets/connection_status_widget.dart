import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/database_data_provider.dart';

/// Widget that displays real-time connection status and sync information
class ConnectionStatusWidget extends StatelessWidget {
  const ConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final databaseData = context.watch<DatabaseDataProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(databaseData, theme),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(databaseData),
            size: 16,
            color: _getIconColor(databaseData, theme),
          ),
          const SizedBox(width: 6),
          Text(
            _getStatusText(databaseData),
            style: theme.textTheme.bodySmall?.copyWith(
              color: _getIconColor(databaseData, theme),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (databaseData.isRealtimeEnabled) ...[
            const SizedBox(width: 4),
            Icon(
              databaseData.isWebSocketConnected 
                ? Icons.wifi 
                : databaseData.isPolling 
                  ? Icons.sync 
                  : Icons.cloud_off,
              size: 12,
              color: _getIconColor(databaseData, theme).withOpacity(0.7),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(DatabaseDataProvider databaseData, ThemeData theme) {
    if (!databaseData.isRealtimeEnabled) {
      return theme.colorScheme.surfaceVariant;
    }
    
    if (databaseData.isConnected) {
      if (databaseData.isWebSocketConnected) {
        return Colors.green.withOpacity(0.1);
      } else if (databaseData.isPolling) {
        return Colors.orange.withOpacity(0.1);
      }
    }
    
    return Colors.red.withOpacity(0.1);
  }

  Color _getIconColor(DatabaseDataProvider databaseData, ThemeData theme) {
    if (!databaseData.isRealtimeEnabled) {
      return theme.colorScheme.onSurfaceVariant;
    }
    
    if (databaseData.isConnected) {
      if (databaseData.isWebSocketConnected) {
        return Colors.green.shade700;
      } else if (databaseData.isPolling) {
        return Colors.orange.shade700;
      }
    }
    
    return Colors.red.shade700;
  }

  IconData _getStatusIcon(DatabaseDataProvider databaseData) {
    if (!databaseData.isRealtimeEnabled) {
      return Icons.sync_disabled;
    }
    
    if (databaseData.isConnected) {
      if (databaseData.isWebSocketConnected) {
        return Icons.cloud_done;
      } else if (databaseData.isPolling) {
        return Icons.sync;
      }
    }
    
    return Icons.cloud_off;
  }

  String _getStatusText(DatabaseDataProvider databaseData) {
    if (!databaseData.isRealtimeEnabled) {
      return 'Sync Off';
    }
    
    if (databaseData.isConnected) {
      if (databaseData.isWebSocketConnected) {
        return 'Live';
      } else if (databaseData.isPolling) {
        return 'Polling';
      }
    }
    
    return 'Offline';
  }
}

/// Expanded connection status widget with detailed information
class DetailedConnectionStatusWidget extends StatelessWidget {
  const DetailedConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final databaseData = context.watch<DatabaseDataProvider>();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
                  'Real-time Sync Status',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: databaseData.isRealtimeEnabled,
                  onChanged: (value) {
                    databaseData.setRealtimeEnabled(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Connection status
            _buildStatusRow(
              theme,
              'Connection Status',
              databaseData.isConnected ? 'Connected' : 'Disconnected',
              databaseData.isConnected ? Colors.green : Colors.red,
              databaseData.isConnected ? Icons.cloud_done : Icons.cloud_off,
            ),
            
            const SizedBox(height: 8),
            
            // Sync method
            _buildStatusRow(
              theme,
              'Sync Method',
              databaseData.isWebSocketConnected 
                ? 'WebSocket (Live)'
                : databaseData.isPolling 
                  ? 'Polling (30s intervals)'
                  : 'Manual Only',
              databaseData.isWebSocketConnected 
                ? Colors.green 
                : databaseData.isPolling 
                  ? Colors.orange 
                  : Colors.grey,
              databaseData.isWebSocketConnected 
                ? Icons.wifi 
                : databaseData.isPolling 
                  ? Icons.sync 
                  : Icons.sync_disabled,
            ),
            
            const SizedBox(height: 8),
            
            // Data counts
            _buildStatusRow(
              theme,
              'Data Counts',
              '${databaseData.departments.length} depts, ${databaseData.menuItems.length} items, ${databaseData.suspendOrders.length} orders',
              theme.colorScheme.primary,
              Icons.storage,
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await databaseData.forceRefresh();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Data refreshed successfully')),
                        );
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Now'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showSyncDetails(context, databaseData);
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Details'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(
    ThemeData theme,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showSyncDetails(BuildContext context, DatabaseDataProvider databaseData) {
    final status = databaseData.getRealtimeStatus();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enabled: ${status['isEnabled']}'),
              Text('Connected: ${status['isConnected']}'),
              Text('Polling: ${status['isPolling']}'),
              Text('WebSocket: ${status['isWebSocketConnected']}'),
              const SizedBox(height: 16),
              const Text('Last Update Times:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...(status['syncStatus']['lastUpdateTimes'] as Map<String, dynamic>).entries.map(
                (entry) => Text('${entry.key}: ${entry.value}'),
              ),
            ],
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
}
