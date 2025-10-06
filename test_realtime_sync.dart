#!/usr/bin/env dart

/// Test script for real-time synchronization functionality
/// Run with: dart test_realtime_sync.dart

import 'dart:io';
import 'dart:convert';

void main() async {
  print('🧪 Testing Real-time Sync Implementation');
  print('=====================================');
  
  // Test 1: Backend Health Check
  print('\n1. Testing Backend Health Check...');
  try {
    final client = HttpClient();
    final request = await client.get('172.20.10.3', 3000, '/api/health');
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      print('✅ Backend is running and healthy');
      print('   Response: $responseBody');
    } else {
      print('❌ Backend returned status: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Backend health check failed: $e');
  }
  
  // Test 2: WebSocket Connection Test
  print('\n2. Testing WebSocket Connection...');
  try {
    final socket = await WebSocket.connect('ws://172.20.10.3:3000/ws');
    print('✅ WebSocket connection established');
    
    // Listen for messages
    socket.listen((message) {
      print('📨 Received WebSocket message: $message');
    });
    
    // Send a ping message
    socket.add(json.encode({
      'type': 'ping',
      'timestamp': DateTime.now().toIso8601String(),
    }));
    
    // Wait a bit for response
    await Future.delayed(const Duration(seconds: 2));
    
    await socket.close();
    print('✅ WebSocket connection closed');
  } catch (e) {
    print('❌ WebSocket connection failed: $e');
  }
  
  // Test 3: Data Sync Endpoint Test
  print('\n3. Testing Data Sync Endpoints...');
  
  final endpoints = [
    '/api/sync/check-changes?type=departments',
    '/api/sync/check-changes?type=products',
    '/api/sync/check-changes?type=suspend_orders',
  ];
  
  for (final endpoint in endpoints) {
    try {
      final client = HttpClient();
      final request = await client.get('172.20.10.3', 3000, endpoint);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      if (response.statusCode == 200) {
        print('✅ $endpoint - OK');
        final data = json.decode(responseBody);
        print('   Last Modified: ${data['lastModified']}');
      } else {
        print('❌ $endpoint - Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ $endpoint - Error: $e');
    }
  }
  
  // Test 4: API Endpoints Test
  print('\n4. Testing Core API Endpoints...');
  
  final apiEndpoints = [
    '/api/departments',
    '/api/products',
    '/api/suspend-orders',
  ];
  
  for (final endpoint in apiEndpoints) {
    try {
      final client = HttpClient();
      final request = await client.get('172.20.10.3', 3000, endpoint);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        print('✅ $endpoint - OK (${data.length} items)');
      } else {
        print('❌ $endpoint - Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ $endpoint - Error: $e');
    }
  }
  
  print('\n🎉 Real-time Sync Test Complete!');
  print('\nNext Steps:');
  print('1. Start the backend server: cd backend && npm start');
  print('2. Run the Flutter app: flutter run');
  print('3. Check the connection status in the app header');
  print('4. Open Settings to configure sync options');
  print('5. Test real-time updates by modifying data in the database');
}
