import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/provider/dio_provider.dart';
import 'package:pass_kuai/repository/analyze_repository.dart';

final analyzeRepositoryProvider = Provider<AnalyzeRepository>((ref) {
  return AnalyzeRepository(dio: ref.watch(dioProvider));
});
