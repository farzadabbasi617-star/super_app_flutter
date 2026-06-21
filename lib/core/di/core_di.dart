import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/network_client.dart';
import '../storage/secure_storage_service.dart';
import '../network/socket/socket_service.dart';
import 'service_locator.dart';

Future<void> initCore() async {
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => SecureStorageService(sl()));
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => NetworkClient(sl()));
  sl.registerLazySingleton<SocketService>(() => SocketService());
}
