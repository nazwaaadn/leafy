import 'package:go_router/go_router.dart';
import 'package:leafy_app/features/onboarding/onboarding_view.dart';
import '../../features/auth/login/login_view.dart';
import '../../features/home/home_view.dart';
import '../../features/history/detail/detail_history_view.dart';

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
      path: AppRoutes.home,
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      path: AppRoutes.historyDetail,
      builder: (context, state) => const HistoryDetailView(),
    ),
  ],
);

class AppRoutes {
  static const onboarding = '/';
  static const login = '/login';
  static const home = '/home';
  static const historyDetail = '/history-detail'; 
}
