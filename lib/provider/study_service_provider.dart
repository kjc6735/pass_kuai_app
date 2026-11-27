import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/provider/saved_word_repository_provider.dart';
import 'package:pass_kuai/provider/today_provider.dart';
import 'package:pass_kuai/service/study_service.dart';

final studyServiceProvider = Provider<StudyService>((ref) {
  return StudyService(
    savedWordRepository: ref.watch(savedWordRepositoryProvider),
    now: ref.watch(clockProvider),
  );
});

/// 오늘 복습할 단어 수. 날짜가 바뀌면 [todayProvider]가 바뀌어 새 기준으로 다시 구독한다.
final dueCountProvider = StreamProvider.autoDispose<int>((ref) {
  final today = ref.watch(todayProvider);
  return ref.watch(studyServiceProvider).watchDueCount(today);
});
