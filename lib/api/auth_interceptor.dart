import 'package:dio/dio.dart';
import 'package:pass_kuai/api/token_storage.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.storage,
    required this.tokenDio,
    required this.retryDio,
  });

  final TokenStorage storage;

  final Dio tokenDio;

  final Dio retryDio;

  static const _retriedKey = 'auth_retried';

  Future<String> _issueToken() async {
    final res = await tokenDio.post<Map<String, dynamic>>('/auth/device');
    final token = res.data?['token'] as String?;
    if (token == null || token.isEmpty) {
      throw StateError('서버가 토큰을 주지 않았어요.');
    }
    await storage.write(token);
    return token;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await storage.read() ?? await _issueToken();
      options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    } on DioException catch (e) {
      handler.reject(e);
    } catch (e) {
      handler.reject(DioException(requestOptions: options, error: e));
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final alreadyRetried = options.extra[_retriedKey] == true;
    if (err.response?.statusCode != 401 || alreadyRetried) {
      return handler.next(err);
    }

    try {
      await storage.clear();
      final token = await _issueToken();
      options.headers['Authorization'] = 'Bearer $token';
      options.extra[_retriedKey] = true;
      final data = options.data;
      if (data is FormData) options.data = data.clone();

      final response = await retryDio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    } catch (_) {
      handler.next(err);
    }
  }
}
