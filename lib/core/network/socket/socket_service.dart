import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  Timer? _heartbeatTimer;

  IO.Socket get socket => _socket!;

  void initSocket(String token) {
    _socket = IO.io('https://api.superapp.com/socket', 
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setAuth({'token': token})
        .setReconnection(true)
        .setReconnectionAttempts(10)
        .setReconnectionDelay(2000)
        .build());

    _socket!.onConnect((_) {
      print('Socket Connected: Starting Heartbeat');
      _startHeartbeat();
    });

    _socket!.onDisconnect((_) {
      print('Socket Disconnected');
      _stopHeartbeat();
    });
  }

  // Heartbeat to keep connection alive and detect silent drops
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _socket!.emit('ping', {'timestamp': DateTime.now().toIso8601String()});
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
  }

  /// Emit with Acknowledgment (Professional approach)
  Future<dynamic> emitWithAck(String event, Map<String, dynamic> data) async {
    final completer = Completer<dynamic>();
    _socket!.emitWithAck(event, data, (response) {
      completer.complete(response);
    });
    return completer.future;
  }

  void listen(String event, Function(dynamic) callback) {
    _socket!.on(event, callback);
  }

  void dispose() {
    _stopHeartbeat();
    _socket?.dispose();
  }
}
