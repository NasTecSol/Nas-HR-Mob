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
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      '${singletonClass.baseURL}',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(999999)
          .setReconnectionDelay(3000)
          .setQuery({'tenantId': tenantId})
          .build(),
    );

    _socket!.onConnect((_) => print('✅ Socket connected'));
    _socket!.onDisconnect((_) => print('❌ Socket disconnected'));
    _socket!.onReconnect((_) => print('🔁 Socket reconnecting'));

    _socket!.on('broadcast-event', (data) {
      final socketData = SocketModel.fromJson(data);
      singletonClass.socketDataList.add(socketData);

      print("📢 Broadcast-event received: $data");

      _handleBroadcastEvent(data, languageCode);
    });

    _socket!.connect();
  }

  Future<void> _handleBroadcastEvent(dynamic data, String languageCode) async {
    try {
      if (data == null) return;

      final isArabic = languageCode == 'ar';
      final message = data['message']?[isArabic ? 'ar' : 'en'] ?? 'New Broadcast Event';

      final log = data['data']?['log'];
      final targetAudience = data['targetAudience'];

      final String? grade = singletonClass.getJWTModel()?.grade;
      final String? empId = singletonClass.getJWTModel()?.employeeId;
      final String? branchId = singletonClass.getJWTModel()?.branchId;

      bool shouldNotify = false;

      if (grade == "L4") {
        final String? logEmpId = log?['employeeId'];
        if (logEmpId != null && empId != null && logEmpId == empId) {
          shouldNotify = true;
        }
      } else if (["L0", "L1", "L2", "L3"].contains(grade)) {
        final String? supervisorId = targetAudience?['supervisors']?.toString();
        final String? targetBranchId = targetAudience?['branchId']?.toString();
        if (supervisorId != null && targetBranchId != null && empId != null && branchId != null) {
          if (supervisorId == empId && targetBranchId == branchId) {
            shouldNotify = true;
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
