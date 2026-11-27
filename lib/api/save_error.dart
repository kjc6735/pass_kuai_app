import 'package:drift/drift.dart' show InvalidDataException;

/// 로컬 DB(단어장) 저장 실패를 사용자 문구로 바꾼다.
///
/// 네트워크 오류용 [friendlyErrorMessage]와 따로 둔다. 저장은 서버를 거치지 않으므로
/// "인터넷 연결" 같은 문구가 나오면 안 되고, 반대로 API 쪽이 drift를 알 필요도 없다.
String friendlySaveErrorMessage(Object error) {
  // withLength(min/max) 위반은 SQL을 보내기 전, 호출한 isolate의 Dart 쪽 검사에서
  // InvalidDataException으로 난다(백그라운드 DB isolate를 거치지 않아 감싸지지 않음).
  if (error is InvalidDataException) {
    return '내용이 너무 길거나 비어 있어서 저장하지 못했어요.';
  }
  return '저장하지 못했어요. 잠시 후 다시 시도해 주세요.';
}
