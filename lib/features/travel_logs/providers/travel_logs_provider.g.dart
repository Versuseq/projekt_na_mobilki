// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_logs_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TravelLogs)
final travelLogsProvider = TravelLogsProvider._();

final class TravelLogsProvider
    extends $NotifierProvider<TravelLogs, List<TravelLog>> {
  TravelLogsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'travelLogsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$travelLogsHash();

  @$internal
  @override
  TravelLogs create() => TravelLogs();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TravelLog> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TravelLog>>(value),
    );
  }
}

String _$travelLogsHash() => r'5bf7497f12f79fd6b114c407d1e73c28478f7f15';

abstract class _$TravelLogs extends $Notifier<List<TravelLog>> {
  List<TravelLog> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<TravelLog>, List<TravelLog>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<TravelLog>, List<TravelLog>>,
              List<TravelLog>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
