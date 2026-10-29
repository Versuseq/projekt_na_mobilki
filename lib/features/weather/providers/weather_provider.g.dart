// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fetchWeather)
final fetchWeatherProvider = FetchWeatherFamily._();

final class FetchWeatherProvider
    extends
        $FunctionalProvider<
          AsyncValue<WeatherData>,
          WeatherData,
          FutureOr<WeatherData>
        >
    with $FutureModifier<WeatherData>, $FutureProvider<WeatherData> {
  FetchWeatherProvider._({
    required FetchWeatherFamily super.from,
    required ({double lat, double lng}) super.argument,
  }) : super(
         retry: null,
         name: r'fetchWeatherProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fetchWeatherHash();

  @override
  String toString() {
    return r'fetchWeatherProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<WeatherData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WeatherData> create(Ref ref) {
    final argument = this.argument as ({double lat, double lng});
    return fetchWeather(ref, lat: argument.lat, lng: argument.lng);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchWeatherProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fetchWeatherHash() => r'7fb1de64a9fc84668a6ee5a0be907dc1328f1389';

final class FetchWeatherFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<WeatherData>,
          ({double lat, double lng})
        > {
  FetchWeatherFamily._()
    : super(
        retry: null,
        name: r'fetchWeatherProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FetchWeatherProvider call({required double lat, required double lng}) =>
      FetchWeatherProvider._(argument: (lat: lat, lng: lng), from: this);

  @override
  String toString() => r'fetchWeatherProvider';
}
