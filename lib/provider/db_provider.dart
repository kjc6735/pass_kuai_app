import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/table/database.dart';

final dbProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
