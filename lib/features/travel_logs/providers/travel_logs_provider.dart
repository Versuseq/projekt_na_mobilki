import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/repositories/auth_repository.dart';
import '../models/travel_log.dart';
import '../../../main.dart';

part 'travel_logs_provider.g.dart';

@riverpod
class TravelLogs extends _$TravelLogs {
  @override
  List<TravelLog> build() {
    final authState = ref.watch(authStateProvider);
    final userId = authState.valueOrNull?.uid;

    if (userId == null) {
      return [];
    }

    return localDb.store
        .box<TravelLog>()
        .getAll()
        .where((log) => log.userId == userId)
        .toList();
  }

  void addLog(TravelLog log) {
    localDb.store.box<TravelLog>().put(log);
    ref.invalidateSelf();
  }

  void updateLog(TravelLog log) {
    localDb.store.box<TravelLog>().put(log);
    ref.invalidateSelf();
  }

  void removeLog(int id) {
    localDb.store.box<TravelLog>().remove(id);
    ref.invalidateSelf();
  }
}

extension AsyncValueX<T> on AsyncValue<T> {
  T? get valueOrNull => asData?.value;
}