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
      'https://dev.nashrms.com',
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
      final isArabic = languageCode == 'ar';
      final message = data?['message']?[isArabic ? 'ar' : 'en'] ?? 'New Broadcast Event';

      NotificationService.showNotification(
        title: 'NAS HR',
        body: message,
      );
    } catch (e) {
      print('❌ Error in _handleBroadcastEvent: $e');
    }
  }


  IO.Socket? get socket => _socket;
}
