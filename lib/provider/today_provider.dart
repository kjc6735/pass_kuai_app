import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 현재 시각. 테스트에서 override 해 시간을 조작한다.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// 오늘 날짜(자정 기준, 시각 0시). 날짜가 바뀌면 새 값을 낸다.
///
/// 다음 자정에 타이머로 갱신하고, 타이머가 늦거나(백그라운드 정지) 기기 시간이
/// 바뀐 경우를 위해 앱이 foreground로 돌아올 때 [TodayNotifier.refresh]도 부른다.
final todayProvider = NotifierProvider.autoDispose<TodayNotifier, DateTime>(
  TodayNotifier.new,
);

class TodayNotifier extends AutoDisposeNotifier<DateTime> {
  late DateTime Function() _now;
  Timer? _timer;

  @override
  DateTime build() {
    _now = ref.watch(clockProvider);
    ref.onDispose(() => _timer?.cancel());
    final today = _today();
    _scheduleNextDay(today);
    return today;
  }

  /// 지금 날짜를 다시 확인해 바뀌었으면 갱신하고, 다음 자정 타이머를 다시 건다.
  void refresh() {
    final today = _today();
    if (today != state) state = today;
    _scheduleNextDay(today);
  }

  DateTime _today() {
    final now = _now();
    return DateTime(now.year, now.month, now.day);
  }

  void _scheduleNextDay(DateTime today) {
    _timer?.cancel();
    final nextDay = DateTime(today.year, today.month, today.day + 1);
    final delay = nextDay.difference(_now());
    // 일찍 울려도(기기 시간 되돌림 등) refresh가 날짜를 다시 보고 타이머를 다시 건다.
    _timer = Timer(delay.isNegative ? Duration.zero : delay, refresh);
  }
}
