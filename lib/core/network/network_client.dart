import 'package:dio/dio.dart';

class NetworkClient {
  final Dio dio;

  NetworkClient(this.dio) {
    dio.options.baseUrl = 'https://api.superapp.com';
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add JWT token to every request
        options.headers['Authorization'] = 'Bearer YOUR_TOKEN_HERE';
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Handle global errors (e.g., 401 Unauthorized)
        if (e.response?.statusCode == 401) {
          print('Session expired. Redirecting to login...');
        }
        return handler.next(e);
      },
    ));
  }
}
