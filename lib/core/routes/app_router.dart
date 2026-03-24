import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/providers/auth_provider.dart';

import '../widgets/main_layout.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/booking/presentation/booking_create_screen.dart';
import '../../features/booking/presentation/booking_detail_screen.dart';
import '../../features/booking/presentation/bookings_screen.dart';
import '../../features/map/presentation/map_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
<<<<<<< HEAD
import '../../features/tours/presentation/boat_list_screen.dart';
import '../../features/tours/presentation/boat_detail_screen.dart';
import '../../features/payment/presentation/payment_screen.dart';
=======
import '../../features/payment/presentation/payment_screen.dart';
import '../../features/booking/domain/booking_model.dart';
>>>>>>> e02dd441d067738dce77013df773bb51c73afe4c

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
  static final _shellNavigatorBookingsKey = GlobalKey<NavigatorState>(debugLabel: 'bookings');
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
<<<<<<< HEAD
        path: '/boat-list',
        builder: (context, state) => const BoatListScreen(),
      ),
      GoRoute(
        path: '/boat-detail/:id',
        builder: (context, state) {
          final tourId = state.pathParameters['id']!;
          return BoatDetailScreen(tourId: tourId);
        },
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) => const PaymentScreen(),
=======
        path: '/payment',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra;
          Booking? booking;
          if (extra is Booking) {
            booking = extra;
          }
          return PaymentScreen(booking: booking);
        },
>>>>>>> e02dd441d067738dce77013df773bb51c73afe4c
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
            navigatorKey: _shellNavigatorBookingsKey,
            routes: [
              GoRoute(
                path: '/bookings',
                builder: (context, state) => const BookingsScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (context, state) {
                      String? boatId;
                      final extra = state.extra;
                      if (extra is Map) {
                        final v = extra['boatId'];
                        if (v is String) boatId = v;
                      }
                      return BookingCreateScreen(prefillBoatId: boatId);
                    },
                  ),
                  GoRoute(
                    path: 'detail/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return BookingDetailScreen(bookingId: id);
                    },
                  ),
                ],
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
