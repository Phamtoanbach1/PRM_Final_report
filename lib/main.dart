import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/booking/providers/booking_provider.dart';

import 'features/tours/providers/tour_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
<<<<<<< HEAD
        ChangeNotifierProvider(create: (_) => TourProvider()),
=======
        ChangeNotifierProvider(create: (_) => BookingProvider()),
>>>>>>> e02dd441d067738dce77013df773bb51c73afe4c
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild router when auth state changes
    context.watch<AuthProvider>();

    return MaterialApp.router(
      title: 'HanCruise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Tự động switch Dark/Light theo máy
      routerConfig: AppRouter.router,
    );
  }
}
