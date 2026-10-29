import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/repositories/auth_repository.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/map/screens/map_screen.dart';
import '../../features/travel_logs/screens/add_log_screen.dart';
import '../../features/travel_logs/screens/logs_list_screen.dart';
import '../../features/weather/screens/weather_screen.dart';
import '../../features/travel_logs/screens/log_details_screen.dart';
import '../../features/travel_logs/screens/edit_log_screen.dart';


part 'app_router.g.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

@riverpod
GoRouter router(Ref ref) {
  final authRepo = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authRepo.authStateChanges),
    redirect: (context, state) {
      final user = ref.read(firebaseAuthProvider).currentUser;
      final isAuthenticated = user != null;
      final isLoggingIn = state.matchedLocation == '/auth';

      if (!isAuthenticated && !isLoggingIn) {
        return '/auth';
      }

      if (isAuthenticated && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'logs_list',
        builder: (context, state) => const LogsListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'add_log',
            builder: (context, state) => const AddLogScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/log/:id',
        name: 'log_details',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return LogDetailsScreen(logId: id);
        },
      ),
      GoRoute(
        path: '/edit-log/:id',
        name: 'edit_log',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return EditLogScreen(logId: id);
        },
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/map',
        name: 'map',
        builder: (context, state) => const MapScreen(),
      ),
      GoRoute(
        path: '/weather',
        name: 'weather',
        builder: (context, state) => const WeatherScreen(),
      ),
    ],
  );
}

extension AsyncValueX<T> on AsyncValue<T> {
  T? get valueOrNull => asData?.value;
}