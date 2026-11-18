import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_kuai/api/api_error.dart';

DioException _http(int status, [Object? data]) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: options, statusCode: status, data: data),
  );
}

void main() {
  test('하루 한도(429)는 서버가 준 한국어 문구를 그대로 보여준다', () {
    final e = _http(429, {'message': '오늘 사용할 수 있는 분석 횟수를 다 썼어요.'});

    expect(friendlyErrorMessage(e), '오늘 사용할 수 있는 분석 횟수를 다 썼어요.');
  });

  test('분당 제한(429)의 영어 문구는 한국어로 바꾼다', () {
    final e = _http(429, {'message': 'ThrottlerException: Too Many Requests'});

    expect(friendlyErrorMessage(e), contains('잠깐 쉬었다가'));
  });

  test('비용 상한(503)은 서버 문구를 보여준다', () {
    final e = _http(503, {'message': '오늘은 서비스 사용량이 많아 잠시 쉬어요. 내일 다시 시도해 주세요.'});

    expect(friendlyErrorMessage(e), contains('내일'));
  });

  test('너무 긴 문장(422)은 서버가 준 안내를 보여준다', () {
    final e = _http(422, {'message': '문장이 너무 길어서 한 번에 분석하지 못했어요. 조금 나눠서 넣어 주세요.'});

    expect(friendlyErrorMessage(e), contains('나눠서'));
  });

  test('인터넷이 끊기면 연결 확인 문구', () {
    final e = DioException(
      requestOptions: RequestOptions(path: '/x'),
      type: DioExceptionType.connectionError,
    );

    expect(friendlyErrorMessage(e), '인터넷 연결을 확인해 주세요.');
  });
}
