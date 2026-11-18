import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/api/auth_interceptor.dart';
import 'package:pass_kuai/api/token_storage.dart';
import 'package:pass_kuai/config/environment.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

BaseOptions _baseOptions() => BaseOptions(
  baseUrl: Environment.baseUrl,
  contentType: 'application/json',
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 90),
);

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(_baseOptions());
  final tokenDio = Dio(_baseOptions());

  dio.interceptors.add(
    AuthInterceptor(
      storage: ref.read(tokenStorageProvider),
      tokenDio: tokenDio,
      retryDio: dio,
    ),
  );

  if (Environment.logNetwork) {
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  return dio;
});
