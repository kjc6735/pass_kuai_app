import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/provider/dio_provider.dart';
import 'package:pass_kuai/repository/stt_repository.dart';

final sttRepositoryProvider = Provider<SttRepository>((ref) {
  return SttRepository(dio: ref.watch(dioProvider));
});
