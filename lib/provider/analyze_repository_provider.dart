import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/model/analyze_result.dart';
import 'package:pass_kuai/provider/dio_provider.dart';

final analyzeRepositoryProvider = Provider<AnalyzeRepository>(
  (ref) => AnalyzeRepository(dio: ref.read(dioProvider)),
);

class AnalyzeRepository {
  final Dio dio;
  AnalyzeRepository({required this.dio});

  Future<AnalyzeResult> analyzeSentence({required String sentence}) async {
    final res = await dio.post(
      '/analyze/sentence',
      data: {'sentence': sentence},
    );
    return AnalyzeResult.fromJson(res.data);
  }

}
