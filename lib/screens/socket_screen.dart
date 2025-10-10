import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:nashr/request_controller/socket_model.dart';
import 'package:nashr/singleton_class.dart';
import '../main.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  SocketService._internal();

  SingletonClass singletonClass = SingletonClass();

  IO.Socket? _socket;

  void initializeSocket(String tenantId, String languageCode) {
    if (_socket != null && _socket!.connected){
      print("⚡ Socket already connected, skipping re-init");
      return;
    }

    String? socketBaseUrl = singletonClass.baseURL;
    if (socketBaseUrl!.endsWith('/api')) {
      socketBaseUrl = socketBaseUrl.substring(0, socketBaseUrl.length - 3);
    }

    _socket = IO.io(
      socketBaseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(999999)
          .setReconnectionDelay(3000)
          .setQuery({'tenantId': tenantId})
          .build(),
    );

    if (kDebugMode){
      _socket!.onConnect((_) => print('✅ Socket connected'));
      _socket!.onDisconnect((_) => print('❌ Socket disconnected'));
      _socket!.onReconnect((_) => print('🔁 Socket reconnecting'));
      _socket!.onConnectError((err) => print('❌ Connection error: $err'));
      _socket!.onError((err) => print('❌ Socket error: $err'));
    }


    _socket!.on('broadcast-event', (data) async {
      final socketData = SocketModel.fromJson(data);
      singletonClass.socketDataList.add(socketData);
      _handleBroadcastEvent(data, languageCode);
      log("📢 Broadcast-event received: $data");
      singletonClass.getClockingData();
      final prefs = await SharedPreferences.getInstance();
      final empId = singletonClass.getJWTModel()?.employeeId ?? "unknown";
      final List<Map<String, dynamic>> jsonList =
      singletonClass.socketDataList.map((e) => e.toJson()).toList();
      await prefs.setString("socket_data_$empId", jsonEncode(jsonList));
    });

    _socket!.connect();
  }
  void disposeSocket() {
    if (_socket != null) {
      _socket!.dispose();
      _socket!.disconnect();
      _socket = null;
      print("🧹 Socket disposed");
    }
  }


  Future<void> _handleBroadcastEvent(dynamic data, String languageCode) async {
    try {
      if (data == null) return;

      final isArabic = languageCode == 'ar';
      final message = data['message']?[isArabic ? 'ar' : 'en'] ?? 'New Broadcast Event';

      final module = data['module'];
      final targetAudience = data['targetAudience'];
      final dynamic log = data['data'];

      final String? grade = singletonClass.getJWTModel()?.grade;
      final String? empId = singletonClass.getJWTModel()?.employeeId;
      final String? branchId = singletonClass.getJWTModel()?.branchId;

      bool shouldNotify = false;

      if (module == "attendance") {
        // ✅ Attendance flow (unchanged)
        if (grade == "L4") {
          final String? logEmpId = log?['employeeId'];
          if (logEmpId != null && empId != null && logEmpId == empId) {
            shouldNotify = true;
          }
        } else if (["L0", "L1", "L2", "L3"].contains(grade)) {
          String? supervisorId;
          String? targetBranchId;
          final String? logEmpId = log?['employeeId'];
          if (logEmpId != null && empId != null && logEmpId == empId) {
            shouldNotify = true;
          }

          if (targetAudience is Map<String, dynamic>) {
            supervisorId = targetAudience['supervisors']?.toString();
            targetBranchId = targetAudience['branchId']?.toString();
          } else if (targetAudience is List) {
            for (var item in targetAudience) {
              if (item is Map<String, dynamic>) {
                supervisorId ??= item['approverId']?.toString();
                targetBranchId ??= item['branchId']?.toString();
              }
            }
          }

          if (supervisorId != null &&
              targetBranchId != null &&
              empId != null &&
              branchId != null) {
            if (supervisorId == empId && targetBranchId == branchId) {
              shouldNotify = true;
            }
          }
        }
      } else if (module == "request") {
        if (grade == "L4") {
          final String? logEmpId = log?['employeeId'];
          if (logEmpId != null && empId != null && logEmpId == empId) {
            shouldNotify = true;
            print("notifcation sex");
          }
        } else if (["L0", "L1", "L2", "L3"].contains(grade)) {
          String? supervisorId;
          final String? logEmpId = log?['employeeId'];
          if (logEmpId != null && empId != null && logEmpId == empId) {
            shouldNotify = true;
            print("notifcation sex");
          }

          if (targetAudience is Map<String, dynamic>) {
            supervisorId = targetAudience['approverId']?.toString();
          } else if (targetAudience is List) {
            for (var item in targetAudience) {
              if (item is Map<String, dynamic>) {
                supervisorId ??= item['approverId']?.toString();
              }
            }
          }

          if (supervisorId != null &&
              empId != null) {
            if (supervisorId == empId) {
              shouldNotify = true;
            }
          }
        }
      } else {
        final currentUserId = singletonClass.getJWTModel()?.employeeId;
        if (targetAudience is Map<String, dynamic>) {
          final participants = targetAudience['participants'];
          if (participants is List && currentUserId != null) {
            if (participants.contains(currentUserId)) {
              shouldNotify = true;
              debugPrint("✅ Notification triggered for user: $currentUserId");
            }
          }
        }
      }

      if (shouldNotify) {
        NotificationService.showNotification(
          title: 'NAS HR',
          body: message,
        );
      }
    } catch (e, st) {
      print('❌ Error in _handleBroadcastEvent: $e\n$st');
    }
  }



  IO.Socket? get socket => _socket;
}
