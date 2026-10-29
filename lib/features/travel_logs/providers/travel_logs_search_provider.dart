import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:io';

import '../models/travel_log.dart';
import 'travel_logs_provider.dart';

part 'travel_logs_search_provider.g.dart';

enum LogFilterType {
  all('Wszystkie'),
  withImage('Ze zdjęciem'),
  withLocation('Z lokalizacją');

  final String label;
  const LogFilterType(this.label);
}

@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

@riverpod
class SelectedFilter extends _$SelectedFilter {
  @override
  LogFilterType build() => LogFilterType.all;

  void setFilter(LogFilterType filter) {
    state = filter;
  }
}

@riverpod
List<TravelLog> filteredTravelLogs(Ref ref) {
  final logs = ref.watch(travelLogsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final filter = ref.watch(selectedFilterProvider);

  return logs.where((log) {
    final matchesQuery = query.isEmpty ||
        log.title.toLowerCase().contains(query) ||
        log.description.toLowerCase().contains(query) ||
        (log.location != null && log.location!.toLowerCase().contains(query));

    final hasValidImage = log.imagePath != null &&
        log.imagePath!.isNotEmpty &&
        File(log.imagePath!).existsSync();

    final matchesFilter = switch (filter) {
      LogFilterType.all => true,
      LogFilterType.withImage => hasValidImage,
      LogFilterType.withLocation =>
      log.location != null && log.location!.trim().isNotEmpty,
    };

    return matchesQuery && matchesFilter;
  }).toList();
}