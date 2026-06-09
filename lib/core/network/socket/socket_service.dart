import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late IO.Socket socket;

  void initSocket(String token) {
    socket = IO.io('https://your-mock-socket-server.com', 
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setAuth({'token': token})
        .build());

    socket.onConnect((_) => print('Connected to Service Socket'));
    socket.onDisconnect((_) => print('Disconnected from Service Socket'));
  }

  void emitEvent(String event, Map<String, dynamic> data) {
    socket.emit(event, data);
  }

  void listenEvent(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }
}
