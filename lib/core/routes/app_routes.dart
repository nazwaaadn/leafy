import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../../features/auth/login/login_view.dart';
import '../../features/home/home_view.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeView(),
    ),
  ],
);

class AppRoutes {
  static const login = '/login';
  static const home = '/home';
}
