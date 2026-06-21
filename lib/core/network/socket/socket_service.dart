import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import '../../utils/app_logger.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;

  IO.Socket get socket => _socket!;

  void initSocket(String token) {
    _socket = IO.io(
      'https://api.superapp.com/socket',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableReconnection() // Handle reconnection manually with Exponential Backoff!
          .build(),
    );

    _socket!.onConnect((_) {
      AppLogger.log(
        'Socket Connected: Starting Heartbeat',
        level: LogLevel.info,
      );
      _reconnectAttempts = 0;
      _reconnectTimer?.cancel();
      _startHeartbeat();
    });

    _socket!.onDisconnect((_) {
      AppLogger.log(
        'Socket Disconnected: Starting Exponential Backoff',
        level: LogLevel.warning,
      );
      _stopHeartbeat();
      _triggerBackoffReconnection(token);
    });
  }

  void _triggerBackoffReconnection(String token) {
    _reconnectTimer?.cancel();
    _reconnectAttempts++;

    // Exponential Backoff calculation: 2s, 4s, 8s, 16s, up to maximum 60 seconds
    final delaySeconds = (2 * _reconnectAttempts).clamp(2, 60);
    AppLogger.log(
      'Socket: Attempting reconnection #$_reconnectAttempts in $delaySeconds seconds...',
      level: LogLevel.info,
    );

    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (_socket != null && !_socket!.connected) {
        _socket!.connect();
      }
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_socket != null && _socket!.connected) {
        _socket!.emit('ping', {'timestamp': DateTime.now().toIso8601String()});
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
  }

  Future<dynamic> emitWithAck(String event, Map<String, dynamic> data) async {
    final completer = Completer<dynamic>();
    if (_socket != null && _socket!.connected) {
      _socket!.emitWithAck(event, data, ack: (response) {
        completer.complete(response);
      });
    } else {
      completer.completeError('Socket not connected');
    }
    return completer.future;
  }

  void listen(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void dispose() {
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    _socket?.dispose();
  }
}
