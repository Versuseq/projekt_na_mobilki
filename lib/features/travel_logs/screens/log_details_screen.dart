import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../weather/providers/weather_provider.dart';
import '../models/travel_log.dart';
import '../providers/travel_logs_provider.dart';

class LogDetailsScreen extends ConsumerWidget {
  final int logId;

  const LogDetailsScreen({
    super.key,
    required this.logId,
  });

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, TravelLog log) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Usuń wpis'),
          content: Text('Czy na pewno chcesz usunąć wpis "${log.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Anuluj'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Usuń'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      ref.read(travelLogsProvider.notifier).removeLog(log.id);
      if (context.mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(travelLogsProvider);

    final log = logs.firstWhere(
          (element) => element.id == logId,
      orElse: () => TravelLog(
        id: -1,
        title: '',
        description: '',
        date: DateTime.now(),
        userId: '',
      ),
    );

    if (log.id == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Szczegóły wpisu')),
        body: const Center(child: Text('Wpis nie został znaleziony.')),
      );
    }

    final hasImage = log.imagePath != null &&
        log.imagePath!.isNotEmpty &&
        File(log.imagePath!).existsSync();

    final formattedDate =
        '${log.date.day.toString().padLeft(2, '0')}.${log.date.month.toString().padLeft(2, '0')}.${log.date.year} r.';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: hasImage ? 280.0 : 120.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                log.title,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
                ),
              ),
              background: hasImage
                  ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(log.imagePath!),
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black38, Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              )
                  : Container(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                tooltip: 'Edytuj wpis',
                onPressed: () {
                  context.pushNamed(
                    'edit_log',
                    pathParameters: {'id': log.id.toString()},
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                tooltip: 'Usuń wpis',
                onPressed: () => _confirmDelete(context, ref, log),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        avatar: const Icon(Icons.calendar_month, size: 18),
                        label: Text(formattedDate),
                      ),
                      if (log.location != null && log.location!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Chip(
                            avatar: const Icon(Icons.location_on, size: 18),
                            label: Text(
                              log.location!,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Wspomnienia i opis',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(120),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        log.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (log.latitude != null && log.longitude != null) ...[
                    Text(
                      'Pogoda w tym miejscu',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _WeatherMiniCard(
                      lat: log.latitude!,
                      lng: log.longitude!,
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (log.latitude != null && log.longitude != null)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.map_outlined),
                        title: const Text('Współrzędne geograficzne'),
                        subtitle: Text(
                          'Lat: ${log.latitude!.toStringAsFixed(4)}, Lng: ${log.longitude!.toStringAsFixed(4)}',
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherMiniCard extends ConsumerWidget {
  final double lat;
  final double lng;

  const _WeatherMiniCard({required this.lat, required this.lng});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(fetchWeatherProvider(lat: lat, lng: lng));

    return weatherAsync.when(
      data: (weather) => Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: ListTile(
          leading: Text(
            '${weather.temperature.toStringAsFixed(1)}°C',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          title: Text(
            weather.weatherDescription,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Wiatr: ${weather.windSpeed} km/h | Wilgotność: ${weather.humidity}%',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(200),
            ),
          ),
        ),
      ),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => Card(
        child: ListTile(
          leading: Icon(
            Icons.cloud_off,
            color: Theme.of(context).colorScheme.error,
          ),
          title: const Text('Błąd ładowania pogody'),
          subtitle: const Text('Kliknij ikonę obok, aby odświeżyć'),
          trailing: IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Spróbuj ponownie',
            onPressed: () {
              ref.invalidate(fetchWeatherProvider(lat: lat, lng: lng));
            },
          ),
        ),
      ),
    );
  }
}