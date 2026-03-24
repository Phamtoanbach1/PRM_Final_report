import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/domain/user_role.dart';
import '../../features/boats/providers/boat_provider.dart';

import '../widgets/main_layout.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/boats/presentation/boats_screen.dart';
import '../../features/boats/presentation/boat_detail_screen.dart';
import '../../features/booking/presentation/booking_create_screen.dart';
import '../../features/booking/presentation/booking_detail_screen.dart';
import '../../features/booking/presentation/bookings_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/payment/presentation/payment_screen.dart';
import '../../features/booking/domain/booking_model.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
  static final _shellNavigatorBookingsKey = GlobalKey<NavigatorState>(debugLabel: 'bookings');
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
        path: '/payment',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          if (auth.role == UserRole.admin) {
            return const Scaffold(
              body: Center(child: Text('Admin không có quyền truy cập thanh toán')),
            );
          }
          final extra = state.extra;
          Booking? booking;
          if (extra is Booking) {
            if (auth.role == UserRole.shopOwner) {
              final boatProvider = Provider.of<BoatProvider>(context, listen: false);
              final ownerBoatIds = boatProvider
                  .boatsForAdminScope(auth.role, auth.displayEmail)
                  .map((e) => e.id)
                  .toSet();
              if (ownerBoatIds.contains(extra.boatId)) {
                return const Scaffold(
                  body: Center(child: Text('Shop owner không thể thanh toán booking thuyền của mình')),
                );
              }
            }
            booking = extra;
          }
          return PaymentScreen(booking: booking);
        },
      ),
      GoRoute(
        path: '/admin',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminDashboardScreen(),
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
                routes: [
                  GoRoute(
                    path: 'boats',
                    builder: (context, state) => const BoatsScreen(),
                  ),
                  GoRoute(
                    path: 'favorites',
                    builder: (context, state) => const BoatsScreen(favoritesOnly: true),
                  ),
                  GoRoute(
                    path: 'boats/:id',
                    builder: (context, state) =>
                        BoatDetailScreen(boatId: state.pathParameters['id']!),
                  ),
                ],
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

      if (state.matchedLocation == '/admin') {
        final role = authProvider.role;
        if (role != UserRole.admin && role != UserRole.shopOwner) {
          return '/home';
        }
      }

      final isAdmin = authProvider.role == UserRole.admin;
      if (isAdmin &&
          (state.matchedLocation.startsWith('/bookings') || state.matchedLocation == '/payment')) {
        return '/home';
      }

      return null;
    },
  );
}
