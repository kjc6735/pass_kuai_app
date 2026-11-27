import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/api/api_error.dart';
import 'package:pass_kuai/components/ui.dart';
import 'package:pass_kuai/model/pronunciation_result.dart';
import 'package:pass_kuai/provider/stt_repository_provider.dart';
import 'package:pass_kuai/provider/tts_service_provider.dart';
import 'package:pass_kuai/theme/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class PronunciationScreen extends ConsumerStatefulWidget {
  const PronunciationScreen({super.key, this.target});

  final Object? target;

  @override
  ConsumerState<PronunciationScreen> createState() =>
      _PronunciationScreenState();
}

enum _Phase { idle, recording, uploading }

class _PronunciationScreenState extends ConsumerState<PronunciationScreen> {
  static const _minDuration = Duration(milliseconds: 500);
  static const _maxDuration = Duration(seconds: 29);
  static const _silenceDb = -45.0;

  final _recorder = AudioRecorder();
  StreamSubscription<Amplitude>? _amplitudeSub;
  Timer? _maxTimer;

  _Phase _phase = _Phase.idle;
  bool _holding = false;
  DateTime? _startedAt;
  double _loudestDb = -160;
  PronunciationResult? _result;

  String get _target => widget.target is String ? widget.target as String : '';

  @override
  void dispose() {
    _maxTimer?.cancel();
    _amplitudeSub?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_phase != _Phase.idle) return;
    await ref.read(ttsServiceProvider).stop();

    if (!await _recorder.hasPermission()) {
      _toast('마이크 권한이 필요해요. 설정에서 마이크를 허용해 주세요.');
      return;
    }

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/practice.m4a';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 16000,
        numChannels: 1,
        bitRate: 32000,
      ),
      path: path,
    );

    _loudestDb = -160;
    _amplitudeSub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .listen((a) {
          if (a.current > _loudestDb) _loudestDb = a.current;
        });
    _maxTimer = Timer(_maxDuration, _stopRecording);
    setState(() {
      _phase = _Phase.recording;
      _startedAt = DateTime.now();
    });
    if (!_holding) await _stopRecording();
  }

  Future<void> _stopRecording() async {
    if (_phase != _Phase.recording) return;
    _maxTimer?.cancel();
    await _amplitudeSub?.cancel();
    _amplitudeSub = null;

    final path = await _recorder.stop();
    final duration = DateTime.now().difference(_startedAt ?? DateTime.now());

    if (path == null) {
      setState(() => _phase = _Phase.idle);
      return;
    }
    if (duration < _minDuration) {
      setState(() => _phase = _Phase.idle);
      _deleteQuietly(path);
      _toast('버튼을 누른 채로 말해 주세요.');
      return;
    }
    if (_loudestDb < _silenceDb) {
      setState(() => _phase = _Phase.idle);
      _deleteQuietly(path);
      _toast('소리가 잘 안 들렸어요. 조금 더 크게 말해 주세요.');
      return;
    }

    setState(() => _phase = _Phase.uploading);
    try {
      final result = await ref
          .read(sttRepositoryProvider)
          .transcribe(path: path, duration: duration, target: _target);
      if (!mounted) return;
      setState(() => _result = result);
    } catch (e) {
      _toast(friendlyErrorMessage(e));
    } finally {
      _deleteQuietly(path);
      if (mounted) setState(() => _phase = _Phase.idle);
    }
  }

  void _deleteQuietly(String path) {
    unawaited(File(path).delete().then((_) {}, onError: (_) {}));
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_target.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('따라 말해보기')),
        body: const MessageView(
          icon: Icons.mic_off_outlined,
          title: '연습할 문장이 없어요',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('따라 말해보기')),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                children: [
                  AppCard(
                    radius: 22,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '목표 문장',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: AppWeights.label,
                                  color: AppColors.sub,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _target,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: AppWeights.hanzi,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconTileButton(
                          tooltip: '목표 문장 듣기',
                          icon: Icons.volume_up_rounded,
                          size: 48,
                          onPressed: _phase == _Phase.idle
                              ? () =>
                                    ref.read(ttsServiceProvider).speak(_target)
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildResult(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              child: _RecordButton(
                phase: _phase,
                onStart: () {
                  _holding = true;
                  _startRecording();
                },
                onStop: () {
                  _holding = false;
                  _stopRecording();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final result = _result;
    if (result == null) {
      return const AppCard(
        radius: 22,
        shadow: false,
        color: AppColors.primarySoft,
        outlined: false,
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 28),
        child: Column(
          children: [
            Icon(
              Icons.record_voice_over_outlined,
              size: 32,
              color: AppColors.primaryText,
            ),
            SizedBox(height: 10),
            Text(
              '먼저 들어 보고,\n아래 버튼을 꾹 누른 채로 따라 말해 보세요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.inkSoft, height: 1.5),
            ),
          ],
        ),
      );
    }

    final comparison = result.comparison;
    return AppCard(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (comparison != null) ...[
            _ScoreHeader(comparison: comparison),
            const SizedBox(height: 18),
            Wrap(
              spacing: 6,
              runSpacing: 8,
              children: [
                for (final s in comparison.syllables)
                  _SyllableChip(syllable: s),
              ],
            ),
            if (comparison.syllables.any((s) => !s.matched)) ...[
              const SizedBox(height: 12),
              const Text(
                '빨간 테두리 글자를 다시 연습해 보세요',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            ],
            if (comparison.extraCount > 0) ...[
              const SizedBox(height: 4),
              Text(
                '문장에 없는 소리가 ${comparison.extraCount}개 더 들렸어요.',
                style: const TextStyle(fontSize: 13, color: AppColors.sub),
              ),
            ],
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),
          ],
          const Text(
            '들린 문장',
            style: TextStyle(
              fontSize: 12,
              fontWeight: AppWeights.label,
              color: AppColors.sub,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            result.text.isEmpty ? '(아무것도 못 알아들었어요)' : result.text,
            style: const TextStyle(fontSize: 17),
          ),
        ],
      ),
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader({required this.comparison});

  final PronunciationComparison comparison;

  String get _headline {
    final rate = comparison.matchRate;
    if (rate >= 0.95) return '완벽해요!';
    if (rate >= 0.7) return '거의 다 맞았어요!';
    if (rate >= 0.4) return '조금만 더 해봐요';
    return '한 번 더 들어볼까요?';
  }

  @override
  Widget build(BuildContext context) {
    final total = comparison.syllables.length;
    final matched = comparison.syllables.where((s) => s.matched).length;
    final percent = (comparison.matchRate * 100).round();

    return Row(
      children: [
        Semantics(
          label: '$percent퍼센트 일치',
          excludeSemantics: true,
          child: SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: comparison.matchRate,
                    strokeWidth: 9,
                    strokeCap: StrokeCap.round,
                    backgroundColor: AppColors.track,
                  ),
                ),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: AppWeights.title,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _headline,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: AppWeights.title,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$total글자 중 $matched글자가 들렸어요',
                style: const TextStyle(fontSize: 14, color: AppColors.sub),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SyllableChip extends StatelessWidget {
  const _SyllableChip({required this.syllable});

  final SyllableMatch syllable;

  @override
  Widget build(BuildContext context) {
    final ok = syllable.matched;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: ok
          ? null
          : BoxDecoration(
              color: AppColors.errorSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error, width: 1.5),
            ),
      child: PinyinHanzi(
        hanzi: syllable.hanzi,
        pinyin: syllable.pinyin,
        hanziSize: 28,
        color: ok ? AppColors.ink : AppColors.error,
        pinyinColor: ok ? AppColors.sub : AppColors.error,
      ),
    );
  }
}

class _RecordButton extends StatelessWidget {
  const _RecordButton({
    required this.phase,
    required this.onStart,
    required this.onStop,
  });

  final _Phase phase;
  final VoidCallback onStart;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final recording = phase == _Phase.recording;
    final uploading = phase == _Phase.uploading;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: '누르고 말하기',
          child: Listener(
            onPointerDown: (_) => onStart(),
            onPointerUp: (_) => onStop(),
            onPointerCancel: (_) => onStop(),
            child: SizedBox(
              width: 124,
              height: 124,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    width: recording ? 124 : 112,
                    height: recording ? 124 : 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: recording
                          ? const Color(0xFFC6D9C0)
                          : AppColors.primaryHalo,
                    ),
                  ),
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      boxShadow: primaryShadow,
                    ),
                    child: uploading
                        ? const Padding(
                            padding: EdgeInsets.all(31),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            recording
                                ? Icons.graphic_eq_rounded
                                : Icons.mic_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          uploading
              ? '확인하는 중…'
              : (recording ? '듣고 있어요. 다 말하면 손을 떼세요' : '꾹 누르고 말한 뒤 손을 떼세요'),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.sub,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
