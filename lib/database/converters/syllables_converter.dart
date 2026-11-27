import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:pass_kuai/model/analyze_result.dart';

/// syllables JSON을 해석하지 못했을 때 불린다. [raw]는 DB에 들어 있던 원본 문자열.
typedef SyllablesDecodeErrorHandler =
    void Function(String raw, Object error, StackTrace stackTrace);

/// `words.syllables`(SQL은 JSON TEXT)를 `List<Syllable>`로 노출한다.
///
/// 해석 실패는 조용히 넘기지 않는다: [onDecodeError]가 원본과 에러를 로그로 남기고
/// debug 빌드에서는 assert로 터뜨린다. release에서는 assert가 빠지므로 빈 리스트로
/// 넘어간다(음절은 성조 색칠용 부가 정보라 없어도 화면은 동작한다).
class SyllablesConverter extends TypeConverter<List<Syllable>, String> {
  const SyllablesConverter();

  /// 테이블 정의가 const 인스턴스를 쓰므로 실패 처리는 static으로 바꿔 끼운다.
  /// 테스트에서 깨진 값을 일부러 읽을 때만 교체하고, 끝나면 [defaultOnDecodeError]로 되돌린다.
  static SyllablesDecodeErrorHandler onDecodeError = defaultOnDecodeError;

  static void defaultOnDecodeError(
    String raw,
    Object error,
    StackTrace stackTrace,
  ) {
    debugPrint('[SyllablesConverter] syllables 해석 실패: raw=$raw error=$error');
    assert(false, 'words.syllables 값이 올바른 JSON이 아니다: $raw ($error)');
  }

  /// [raw]를 음절 목록으로 해석한다. 깨져 있으면 예외를 던진다.
  static List<Syllable> parse(String raw) => List.unmodifiable(
    (jsonDecode(raw) as List).map(
      (e) => Syllable.fromJson(e as Map<String, dynamic>),
    ),
  );

  /// [raw]가 올바른 음절 JSON인지. 마이그레이션에서 깨진 옛 데이터를 찾을 때 쓴다.
  static bool isValid(String raw) {
    try {
      parse(raw);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  List<Syllable> fromSql(String fromDb) {
    try {
      return parse(fromDb);
    } catch (error, stackTrace) {
      onDecodeError(fromDb, error, stackTrace);
      return const [];
    }
  }

  @override
  String toSql(List<Syllable> value) =>
      jsonEncode(value.map((s) => s.toJson()).toList());
}
