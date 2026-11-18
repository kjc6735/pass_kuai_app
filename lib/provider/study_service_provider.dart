import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/provider/saved_word_repository_provider.dart';
import 'package:pass_kuai/service/study_service.dart';

final studyServiceProvider = Provider<StudyService>((ref) {
  return StudyService(savedWordRepository: ref.read(savedWordRepositoryProvider));
});

final dueCountProvider = StreamProvider.autoDispose<int>((ref) {
  return ref.read(studyServiceProvider).watchDueCount();
});
