import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show InvalidDataException;
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_kuai/api/save_error.dart';

void main() {
  test('길이/빈 값 검사(InvalidDataException) 위반은 구체적인 문구', () {
    expect(
      friendlySaveErrorMessage(InvalidDataException('sentence: too long')),
      '내용이 너무 길거나 비어 있어서 저장하지 못했어요.',
    );
  });

  test('그 밖의 저장 실패는 일반 저장 실패 문구', () {
    expect(
      friendlySaveErrorMessage(StateError('UNIQUE constraint failed')),
      '저장하지 못했어요. 잠시 후 다시 시도해 주세요.',
    );
  });

  test('네트워크 예외가 섞여 들어와도 연결 문구가 아닌 저장 실패 문구', () {
    final e = DioException(
      requestOptions: RequestOptions(path: '/x'),
      type: DioExceptionType.connectionError,
    );

    expect(friendlySaveErrorMessage(e), '저장하지 못했어요. 잠시 후 다시 시도해 주세요.');
  });
}
