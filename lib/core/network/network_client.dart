import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_endpoints.dart';
import '../error/failures.dart';
import '../storage/secure_storage_service.dart';
import '../di/service_locator.dart';

class NetworkClient {
  final Dio dio;

  NetworkClient(this.dio) {
    dio.options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    dio.interceptors.add(AuthInterceptor());
    dio.interceptors.add(ErrorInterceptor());
    
    // SECURITY FIX: Only enable logging in debug mode to prevent leaking sensitive data in release
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await dio.delete(path);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Failure _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ConnectionFailure();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) return const UnauthorizedFailure();
        if (statusCode == 400) return ValidationFailure(e.response?.data['message'] ?? 'Invalid request');
        return ServerFailure(e.response?.data['message'] ?? 'Something went wrong', statusCode: statusCode);
      default:
        return ServerFailure('An unexpected error occurred');
    }
  }
}

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final storage = sl<SecureStorageService>();
    final token = await storage.getToken();
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, RequestInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Global Auth Error handled here
    }
    super.onError(err, handler);
  }
}
