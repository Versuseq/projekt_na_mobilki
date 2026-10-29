// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_logs_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchQuery)
final searchQueryProvider = SearchQueryProvider._();

final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  SearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'705b7bae115c1d6132c5db12668a80127c3bfd99';

abstract class _$SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SelectedFilter)
final selectedFilterProvider = SelectedFilterProvider._();

final class SelectedFilterProvider
    extends $NotifierProvider<SelectedFilter, LogFilterType> {
  SelectedFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedFilterHash();

  @$internal
  @override
  SelectedFilter create() => SelectedFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LogFilterType value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LogFilterType>(value),
    );
  }
}

String _$selectedFilterHash() => r'96b4fa769338342d32a9bfaa3090b737b621cfe8';

abstract class _$SelectedFilter extends $Notifier<LogFilterType> {
  LogFilterType build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LogFilterType, LogFilterType>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LogFilterType, LogFilterType>,
              LogFilterType,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredTravelLogs)
final filteredTravelLogsProvider = FilteredTravelLogsProvider._();

final class FilteredTravelLogsProvider
    extends
        $FunctionalProvider<List<TravelLog>, List<TravelLog>, List<TravelLog>>
    with $Provider<List<TravelLog>> {
  FilteredTravelLogsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredTravelLogsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredTravelLogsHash();

  @$internal
  @override
  $ProviderElement<List<TravelLog>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<TravelLog> create(Ref ref) {
    return filteredTravelLogs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TravelLog> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TravelLog>>(value),
    );
  }
}

String _$filteredTravelLogsHash() =>
    r'90024ca7c4fadfe095b673ac9643966dda526231';
