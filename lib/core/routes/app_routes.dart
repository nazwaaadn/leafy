import 'package:go_router/go_router.dart';
import 'package:leafy_app/features/onboarding/onboarding_view.dart';
import '../../features/auth/login/login_view.dart';
import '../../features/auth/register/register_view.dart';
import '../../features/home/home_view.dart';
import '../../features/history/history_view.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.onboarding,
  routes: [
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingView(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterView(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      path: AppRoutes.history,
      builder: (context, state) => const HistoryView(),
    ),
  ],
);

class AppRoutes {
  static const onboarding = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const history = '/history';
}