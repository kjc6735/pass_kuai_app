import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/config/environment.dart';

final dioProvider = Provider<Dio>((ref) {
  print('>>> baseUrl = ${Environment.baseUrl}');
  final dio = Dio(
    BaseOptions(baseUrl: Environment.baseUrl, contentType: 'application/json'),
  );

  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  return dio;
});
