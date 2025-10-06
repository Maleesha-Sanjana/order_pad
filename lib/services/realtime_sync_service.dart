import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;

/// Service responsible for real-time database synchronization
/// Supports both polling and WebSocket connections for live updates
class RealtimeSyncService {
  static final RealtimeSyncService _instance = RealtimeSyncService._internal();
  factory RealtimeSyncService() => _instance;
  RealtimeSyncService._internal();

  // Connection configuration
  static const String _baseUrl = 'http://172.20.10.3:3000';
  static const String _wsUrl = 'ws://172.20.10.3:3000';
  static const Duration _pollingInterval = Duration(seconds: 30);
  static const Duration _connectionTimeout = Duration(seconds: 10);

  // Connection state
  bool _isConnected = false;
  bool _isPolling = false;
  bool _isWebSocketConnected = false;
  Timer? _pollingTimer;
  WebSocketChannel? _webSocketChannel;
  StreamSubscription? _webSocketSubscription;

  // Callbacks for data updates
  final Map<String, Function> _updateCallbacks = {};
  final Map<String, DateTime> _lastUpdateTimes = {};

  // Connection status stream
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  // Data change notifications stream
  final StreamController<Map<String, dynamic>> _dataChangeController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get dataChanges => _dataChangeController.stream;

  // Getters
  bool get isConnected => _isConnected;
  bool get isPolling => _isPolling;
  bool get isWebSocketConnected => _isWebSocketConnected;

  /// Initialize the real-time sync service
  Future<void> initialize() async {
    print('🔄 Initializing RealtimeSyncService...');
    
    try {
      // Test initial connection
      await _testConnection();
      
      // Start WebSocket connection
      await _connectWebSocket();
      
      // Start polling as fallback
      _startPolling();
      
      _isConnected = true;
      _connectionStatusController.add(true);
      print('✅ RealtimeSyncService initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize RealtimeSyncService: $e');
      _isConnected = false;
      _connectionStatusController.add(false);
      
      // Fallback to polling only
      _startPolling();
    }
  }

  /// Test connection to the backend
  Future<void> _testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_connectionTimeout);
      
      if (response.statusCode == 200) {
        print('✅ Backend connection test successful');
      } else {
        throw Exception('Backend returned status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Backend connection test failed: $e');
      throw e;
    }
  }

  /// Connect to WebSocket for real-time updates
  Future<void> _connectWebSocket() async {
    try {
      print('🔌 Connecting to WebSocket...');
      
      _webSocketChannel = IOWebSocketChannel.connect(
        '$_wsUrl/ws',
        connectTimeout: _connectionTimeout,
      );
      
      _webSocketSubscription = _webSocketChannel!.stream.listen(
        (data) => _handleWebSocketMessage(data),
        onError: (error) => _handleWebSocketError(error),
        onDone: () => _handleWebSocketDisconnect(),
      );
      
      _isWebSocketConnected = true;
      print('✅ WebSocket connected successfully');
    } catch (e) {
      print('❌ WebSocket connection failed: $e');
      _isWebSocketConnected = false;
      throw e;
    }
  }

  /// Handle incoming WebSocket messages
  void _handleWebSocketMessage(dynamic data) {
    try {
      final message = json.decode(data);
      print('📨 WebSocket message received: ${message['type']}');
      
      switch (message['type']) {
        case 'data_change':
          _handleDataChange(message['data']);
          break;
        case 'connection_status':
          print('🔗 WebSocket connection status: ${message['status']}');
          break;
        default:
          print('⚠️ Unknown WebSocket message type: ${message['type']}');
      }
    } catch (e) {
      print('❌ Error parsing WebSocket message: $e');
    }
  }

  /// Handle WebSocket errors
  void _handleWebSocketError(dynamic error) {
    print('❌ WebSocket error: $error');
    _isWebSocketConnected = false;
    _connectionStatusController.add(false);
    
    // Attempt to reconnect after a delay
    Timer(const Duration(seconds: 5), () {
      if (!_isWebSocketConnected) {
        _connectWebSocket();
      }
    });
  }

  /// Handle WebSocket disconnection
  void _handleWebSocketDisconnect() {
    print('🔌 WebSocket disconnected');
    _isWebSocketConnected = false;
    _connectionStatusController.add(false);
    
    // Attempt to reconnect
    Timer(const Duration(seconds: 3), () {
      _connectWebSocket();
    });
  }

  /// Start polling for data changes
  void _startPolling() {
    if (_isPolling) return;
    
    print('⏰ Starting polling for data changes...');
    _isPolling = true;
    
    _pollingTimer = Timer.periodic(_pollingInterval, (timer) async {
      await _pollForChanges();
    });
  }

  /// Stop polling
  void _stopPolling() {
    if (!_isPolling) return;
    
    print('⏹️ Stopping polling...');
    _isPolling = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Poll for data changes
  Future<void> _pollForChanges() async {
    try {
      // Check for changes in different data types
      await _checkDataChanges('departments');
      await _checkDataChanges('products');
      await _checkDataChanges('suspend_orders');
      await _checkDataChanges('orders');
    } catch (e) {
      print('❌ Error polling for changes: $e');
    }
  }

  /// Check for changes in specific data type
  Future<void> _checkDataChanges(String dataType) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/sync/check-changes?type=$dataType'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_connectionTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final lastModified = DateTime.parse(data['lastModified']);
        
        if (_shouldUpdate(dataType, lastModified)) {
          _triggerDataUpdate(dataType, data);
        }
      }
    } catch (e) {
      print('❌ Error checking changes for $dataType: $e');
    }
  }

  /// Determine if data should be updated based on last modification time
  bool _shouldUpdate(String dataType, DateTime lastModified) {
    final lastUpdate = _lastUpdateTimes[dataType];
    if (lastUpdate == null) return true;
    return lastModified.isAfter(lastUpdate);
  }

  /// Handle data change from WebSocket
  void _handleDataChange(Map<String, dynamic> data) {
    print('📊 Processing WebSocket data change: $data');
    
    final dataType = data['dataType'] as String?;
    if (dataType != null) {
      _triggerDataUpdate(dataType, data);
    }
  }

  /// Trigger data update for a specific type
  void _triggerDataUpdate(String dataType, Map<String, dynamic> data) {
    print('🔄 Triggering update for $dataType');
    
    _lastUpdateTimes[dataType] = DateTime.now();
    
    // Notify registered callbacks
    final callback = _updateCallbacks[dataType];
    if (callback != null) {
      callback();
    }
    
    // Broadcast data change
    _dataChangeController.add({
      'type': dataType,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Register a callback for data type updates
  void registerUpdateCallback(String dataType, Function callback) {
    _updateCallbacks[dataType] = callback;
    print('📝 Registered update callback for $dataType');
  }

  /// Unregister a callback for data type updates
  void unregisterUpdateCallback(String dataType) {
    _updateCallbacks.remove(dataType);
    print('🗑️ Unregistered update callback for $dataType');
  }

  /// Force refresh of all data
  Future<void> forceRefresh() async {
    print('🔄 Force refreshing all data...');
    
    // Trigger all registered callbacks
    for (final entry in _updateCallbacks.entries) {
      try {
        entry.value();
      } catch (e) {
        print('❌ Error in callback for ${entry.key}: $e');
      }
    }
  }

  /// Enable real-time sync for specific data types
  void enableSyncFor(List<String> dataTypes) {
    print('🔔 Enabling sync for: ${dataTypes.join(', ')}');
    
    for (final dataType in dataTypes) {
      _lastUpdateTimes[dataType] = DateTime.now();
    }
  }

  /// Disable real-time sync for specific data types
  void disableSyncFor(List<String> dataTypes) {
    print('🔕 Disabling sync for: ${dataTypes.join(', ')}');
    
    for (final dataType in dataTypes) {
      _lastUpdateTimes.remove(dataType);
      _updateCallbacks.remove(dataType);
    }
  }

  /// Get sync status for all data types
  Map<String, dynamic> getSyncStatus() {
    return {
      'isConnected': _isConnected,
      'isPolling': _isPolling,
      'isWebSocketConnected': _isWebSocketConnected,
      'lastUpdateTimes': Map.from(_lastUpdateTimes),
      'registeredCallbacks': _updateCallbacks.keys.toList(),
    };
  }

  /// Disconnect and cleanup
  Future<void> disconnect() async {
    print('🔌 Disconnecting RealtimeSyncService...');
    
    _isConnected = false;
    _isPolling = false;
    _isWebSocketConnected = false;
    
    // Stop polling
    _stopPolling();
    
    // Close WebSocket
    _webSocketSubscription?.cancel();
    _webSocketChannel?.sink.close();
    _webSocketChannel = null;
    
    // Clear callbacks
    _updateCallbacks.clear();
    _lastUpdateTimes.clear();
    
    _connectionStatusController.add(false);
    print('✅ RealtimeSyncService disconnected');
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _connectionStatusController.close();
    _dataChangeController.close();
  }
}
