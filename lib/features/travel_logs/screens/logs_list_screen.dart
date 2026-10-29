import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/providers/theme_provider.dart';
import '../../auth/repositories/auth_repository.dart';
import '../models/travel_log.dart';
import '../providers/travel_logs_provider.dart';
import '../providers/travel_logs_search_provider.dart';

class LogsListScreen extends ConsumerStatefulWidget {
  const LogsListScreen({super.key});

  @override
  ConsumerState<LogsListScreen> createState() => _LogsListScreenState();
}

class _LogsListScreenState extends ConsumerState<LogsListScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredLogs = ref.watch(filteredTravelLogsProvider);
    final currentFilter = ref.watch(selectedFilterProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dziennik Podróży'),
        actions: [
          IconButton(
            icon: Icon(
              switch (ref.watch(themeModeProvider)) {
                ThemeMode.light => Icons.light_mode,
                ThemeMode.dark => Icons.dark_mode,
                ThemeMode.system => Icons.brightness_auto,
              },
            ),
            tooltip: 'Zmień motyw',
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Mapa',
            onPressed: () => context.pushNamed('map'),
          ),
          IconButton(
            icon: const Icon(Icons.wb_sunny_outlined),
            tooltip: 'Pogoda',
            onPressed: () => context.pushNamed('weather'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Wyloguj się',
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) {
                context.go('/auth');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Column(
              children: [
                SearchBar(
                  controller: _searchController,
                  hintText: 'Szukaj po tytule, opisie lub miejscu...',
                  leading: const Icon(Icons.search),
                  trailing: searchQuery.isNotEmpty
                      ? [
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).clear();
                      },
                    ),
                  ]
                      : null,
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).updateQuery(value);
                  },
                  elevation: WidgetStateProperty.all(1),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: LogFilterType.values.map((filter) {
                      final isSelected = currentFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(filter.label),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              ref
                                  .read(selectedFilterProvider.notifier)
                                  .setFilter(filter);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: filteredLogs.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_outlined,
                    size: 70,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    searchQuery.isNotEmpty || currentFilter != LogFilterType.all
                        ? 'Brak wyników wyszukiwania'
                        : 'Brak wpisów o podróżach',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    searchQuery.isNotEmpty || currentFilter != LogFilterType.all
                        ? 'Spróbuj zmienić frazę lub filtry'
                        : 'Dodaj swój pierwszy wyjazd, klikając przycisk poniżej!',
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: filteredLogs.length,
              itemBuilder: (context, index) {
                final log = filteredLogs[index];
                return _TravelLogCard(log: log);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('add_log'),
        icon: const Icon(Icons.add),
        label: const Text('Dodaj podróż'),
      ),
    );
  }
}

class _TravelLogCard extends ConsumerWidget {
  final TravelLog log;

  const _TravelLogCard({required this.log});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Usuń wpis'),
          content: Text('Czy na pewno chcesz usunąć wpis "${log.title}"? Tej operacji nie można cofnąć.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Anuluj'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Usuń'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      ref.read(travelLogsProvider.notifier).removeLog(log.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattedDate =
        '${log.date.day.toString().padLeft(2, '0')}.${log.date.month.toString().padLeft(2, '0')}.${log.date.year}';

    final hasImage = log.imagePath != null &&
        log.imagePath!.isNotEmpty &&
        File(log.imagePath!).existsSync();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.pushNamed(
            'log_details',
            pathParameters: {'id': log.id.toString()},
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              Image.file(
                File(log.imagePath!),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          log.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Edytuj wpis',
                            onPressed: () {
                              context.pushNamed(
                                'edit_log',
                                pathParameters: {'id': log.id.toString()},
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            tooltip: 'Usuń wpis',
                            onPressed: () => _confirmDelete(context, ref),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (log.location != null && log.location!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          log.location!,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    log.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}