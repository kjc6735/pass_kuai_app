import 'package:dio/dio.dart';
import 'package:pass_kuai/model/analyze_result.dart';

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
