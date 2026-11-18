import 'package:dio/dio.dart';

String friendlyErrorMessage(Object error) {
  if (error is! DioException) return '문제가 생겼어요. 잠시 후 다시 시도해 주세요.';

  switch (error.type) {
    case DioExceptionType.connectionError:
      return '인터넷 연결을 확인해 주세요.';
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return '응답이 늦어요. 잠시 후 다시 시도해 주세요.';
    default:
      break;
  }

  final status = error.response?.statusCode;
  final serverMessage = _serverMessage(error.response?.data);

  switch (status) {
    case 400:
      return '입력한 내용을 확인해 주세요.';
    case 401:
      return '앱을 다시 실행해 주세요.';
    case 413:
      return '녹음이 너무 길어요. 짧게 다시 말해 주세요.';
    case 422:
      // 문장이 너무 길어 AI 출력이 끊긴 경우 등. 서버가 이유를 한국어로 준다.
      return serverMessage != null && _hasKorean(serverMessage)
          ? serverMessage
          : '입력한 내용을 처리하지 못했어요. 조금 나눠서 다시 시도해 주세요.';
    case 429:
      if (serverMessage != null && _hasKorean(serverMessage)) return serverMessage;
      return '너무 빨리 요청했어요. 잠깐 쉬었다가 다시 해 주세요.';
    case 503:
      return serverMessage != null && _hasKorean(serverMessage)
          ? serverMessage
          : '지금은 서비스를 쓸 수 없어요. 잠시 후 다시 시도해 주세요.';
    default:
      return '문제가 생겼어요. 잠시 후 다시 시도해 주세요.';
  }
}

String? _serverMessage(Object? data) {
  if (data is Map && data['message'] is String) return data['message'] as String;
  return null;
}

bool _hasKorean(String s) => RegExp(r'[가-힣]').hasMatch(s);
