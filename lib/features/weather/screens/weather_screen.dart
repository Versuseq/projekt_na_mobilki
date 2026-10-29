import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../travel_logs/providers/travel_logs_provider.dart';
import '../providers/weather_provider.dart';

class WeatherLocationOption {
  final String name;
  final double latitude;
  final double longitude;

  const WeatherLocationOption({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is WeatherLocationOption &&
              runtimeType == other.runtimeType &&
              latitude == other.latitude &&
              longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  WeatherLocationOption? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(travelLogsProvider);

    final validLogs = logs
        .where((log) => log.latitude != null && log.longitude != null)
        .toList();

    final List<DropdownMenuEntry<WeatherLocationOption>> menuEntries =
    validLogs.map((log) {
      final locationName = log.location != null && log.location!.isNotEmpty
          ? '${log.title} (${log.location})'
          : log.title;

      return DropdownMenuEntry<WeatherLocationOption>(
        value: WeatherLocationOption(
          name: locationName,
          latitude: log.latitude!,
          longitude: log.longitude!,
        ),
        label: locationName,
        leadingIcon: const Icon(Icons.place_outlined),
      );
    }).toList();

    final currentLocation = _selectedLocation ??
        (menuEntries.isNotEmpty ? menuEntries.first.value : null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pogoda'),
      ),
      body: validLogs.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off_outlined,
                size: 70,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Brak zapisanych lokalizacji',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Dodaj wyjazd z lokalizacją GPS, aby móc sprawdzać tu pogodę.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownMenu<WeatherLocationOption>(
              width: MediaQuery.of(context).size.width - 32,
              requestFocusOnTap: false,
              enableFilter: false,
              leadingIcon: const Icon(Icons.place_outlined),
              label: const Text('Wybierz miejsce z podróży'),
              initialSelection: currentLocation,
              dropdownMenuEntries: menuEntries,
              onSelected: (WeatherLocationOption? option) {
                if (option != null) {
                  setState(() {
                    _selectedLocation = option;
                  });
                }
              },
            ),
          ),

          Expanded(
            child: currentLocation != null
                ? _WeatherContent(
              lat: currentLocation.latitude,
              lng: currentLocation.longitude,
              locationName: currentLocation.name,
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _WeatherContent extends ConsumerWidget {
  final double lat;
  final double lng;
  final String locationName;

  const _WeatherContent({
    required this.lat,
    required this.lng,
    required this.locationName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(fetchWeatherProvider(lat: lat, lng: lng));

    return weatherAsync.when(
      data: (weather) => SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              locationName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      '${weather.temperature.toStringAsFixed(1)}°C',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weather.weatherDescription,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Odczuwalna: ${weather.apparentTemperature.toStringAsFixed(1)}°C',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _WeatherMetricCard(
                  icon: Icons.water_drop,
                  label: 'Wilgotność',
                  value: '${weather.humidity}%',
                ),
                _WeatherMetricCard(
                  icon: Icons.air,
                  label: 'Wiatr',
                  value: '${weather.windSpeed} km/h',
                  subtitle: weather.windDirectionText,
                ),
                _WeatherMetricCard(
                  icon: Icons.compress,
                  label: 'Ciśnienie',
                  value: '${weather.pressure.round()} hPa',
                ),
                _WeatherMetricCard(
                  icon: Icons.wb_sunny,
                  label: 'Indeks UV',
                  value: weather.uvIndexMax.toStringAsFixed(1),
                ),
                _WeatherMetricCard(
                  icon: Icons.wb_twilight,
                  label: 'Wschód słońca',
                  value: weather.sunrise,
                ),
                _WeatherMetricCard(
                  icon: Icons.nights_stay,
                  label: 'Zachód słońca',
                  value: weather.sunset,
                ),
              ],
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Nie udało się pobrać danych pogody',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sprawdź połączenie z internetem i spróbuj ponownie.',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  ref.invalidate(fetchWeatherProvider(lat: lat, lng: lng));
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Spróbuj ponownie'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherMetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  const _WeatherMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}