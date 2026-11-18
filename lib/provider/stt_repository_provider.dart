import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/model/pronunciation_result.dart';
import 'package:pass_kuai/provider/dio_provider.dart';

final sttRepositoryProvider = Provider<SttRepository>(
  (ref) => SttRepository(dio: ref.read(dioProvider)),
);

class SttRepository {
  SttRepository({required this.dio});

  final Dio dio;

  Future<PronunciationResult> transcribe({
    required String path,
    required Duration duration,
    required String target,
  }) async {
    final form = FormData.fromMap({
      'durationMs': duration.inMilliseconds.toString(),
      'target': target,
      'file': await MultipartFile.fromFile(
        path,
        filename: 'speech.m4a',
        contentType: DioMediaType('audio', 'mp4'),
      ),
    });

    final res = await dio.post<Map<String, dynamic>>('/stt/transcribe', data: form);
    return PronunciationResult.fromJson(res.data ?? const {});
  }
}
