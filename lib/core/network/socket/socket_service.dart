import 'package:socket_io_client/socket_io_client.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late IO.Socket socket;

  void initSocket(String token) {
    socket = IO.io('YOUR_BACKEND_URL', 
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setAuth({'token': token})
        .build());

    socket.onConnect((_) {
      print('Connected to Socket.io server');
    });

    socket.onDisconnect((_) {
      print('Disconnected from Socket.io server');
    });

    socket.onConnectError((data) => print('Connect Error: $data'));
    socket.on('connect_error', (data) => print('Connect Error: $data'));
  }

  void joinRoom(String roomId) {
    socket.emit('join', {'room': roomId});
  }

  void sendEvent(String event, Map<String, dynamic> data) {
    socket.emit(event, data);
  }

  void listenToEvent(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }
}
