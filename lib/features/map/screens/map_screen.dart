import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../travel_logs/providers/travel_logs_provider.dart';
import '../../travel_logs/models/travel_log.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(travelLogsProvider);

    final logsWithCoords = logs.where(
          (log) => log.latitude != null && log.longitude != null,
    ).toList();

    final initialCenter = logsWithCoords.isNotEmpty
        ? LatLng(logsWithCoords.first.latitude!, logsWithCoords.first.longitude!)
        : const LatLng(52.2297, 21.0122);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Podróży'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: initialCenter,
          initialZoom: 5.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.projekt_bilski',
          ),
          MarkerLayer(
            markers: logsWithCoords.map((log) {
              return Marker(
                point: LatLng(log.latitude!, log.longitude!),
                width: 44,
                height: 44,
                child: GestureDetector(
                  onTap: () => _showLogPreview(context, log),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.redAccent,
                    size: 40,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showLogPreview(BuildContext context, TravelLog log) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (log.location != null && log.location!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(log.location!, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  log.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.pushNamed(
                        'log_details',
                        pathParameters: {'id': log.id.toString()},
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Zobacz szczegóły'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

//54.330898 18.139629