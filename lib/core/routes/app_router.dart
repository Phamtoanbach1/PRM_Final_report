import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/providers/auth_provider.dart';

import '../widgets/main_layout.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/tours/presentation/tours_screen.dart';
import '../../features/map/presentation/map_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/booking/pages/boat_list_page.dart';
import '../../features/booking/pages/boat_detail_page.dart';
import '../../features/booking/pages/booking_form_page.dart';
import '../../features/booking/pages/booking_list_page.dart';
import '../../features/booking/pages/booking_detail_page.dart';
import '../../features/booking/pages/operator_booking_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
  static final _shellNavigatorToursKey = GlobalKey<NavigatorState>(debugLabel: 'tours');
  static final _shellNavigatorMapKey = GlobalKey<NavigatorState>(debugLabel: 'map');
  static final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

  static final router = GoRouter(
    initialLocation: '/splash',
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/boats',
        builder: (context, state) => const BoatListPage(),
      ),
      GoRoute(
        path: '/boat/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0');
          return BoatDetailPage(boatId: id ?? 1);
        },
      ),
      GoRoute(
        path: '/boat/:id/book',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0');
          return BookingFormPage(boatId: id ?? 1);
        },
      ),
      GoRoute(
        path: '/bookings',
        builder: (context, state) => const BookingListPage(),
      ),
      GoRoute(
        path: '/bookings/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0');
          return BookingDetailPage(bookingId: id ?? 0);
        },
      ),
      GoRoute(
        path: '/operator/bookings',
        builder: (context, state) => const OperatorBookingPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorToursKey,
            routes: [
              GoRoute(
                path: '/tours',
                builder: (context, state) => const ToursScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorMapKey,
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isAuthenticated;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';
      final isGoingToSplash = state.matchedLocation == '/splash';

      if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister && !isGoingToSplash) {
        return '/login';
      }

      if (isLoggedIn && (isGoingToLogin || isGoingToRegister || isGoingToSplash)) {
        return '/home';
      }

      return null;
    },
  );
}
