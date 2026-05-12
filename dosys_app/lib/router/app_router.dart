import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/medications/screens/medications_screen.dart';
import '../features/medications/screens/edit_medication_screen.dart';
import '../features/medications/screens/add_medication_screen.dart';
import '../features/medications/screens/dose_alert_screen.dart';
import '../features/medications/data/medication_models.dart';
import '../features/device/screens/device_screen.dart';
import '../features/insights/screens/insights_screen.dart';
import '../features/insights/screens/alerts_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/medications', builder: (context, state) => const MedicationsScreen()),
    GoRoute(
      path: '/medications/add',
      builder: (context, state) {
        final deviceId = state.extra as int;
        return AddMedicationScreen(deviceId: deviceId);
      },
    ),
    GoRoute(
      path: '/medications/:id',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return EditMedicationScreen(
          container: extra['container'] as ContainerModel,
          deviceId: extra['deviceId'] as int,
        );
      },
    ),
    GoRoute(
      path: '/dose-alert',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return DoseAlertScreen(
          deviceId: extra['deviceId'] as int,
          schedule: extra['schedule'] as ScheduleModel,
          container: extra['container'] as ContainerModel,
        );
      },
    ),
    GoRoute(path: '/device', builder: (context, state) => const DeviceScreen()),
    GoRoute(path: '/insights', builder: (context, state) => const InsightsScreen()),
    GoRoute(path: '/alerts', builder: (context, state) => const AlertsScreen()),
    GoRoute(path: '/profile', builder: (context, state) => const _Placeholder('Profile')),
  ],
);

class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('$title — coming soon')));
  }
}
