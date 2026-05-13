import 'package:go_router/go_router.dart';
import 'package:leafy_app/features/onboarding/onboarding_view.dart';
import 'package:leafy_app/features/splash/splash_view.dart';
import '../../features/auth/login/login_view.dart';
import '../../features/auth/register/register_view.dart';
import '../../features/home/home_view.dart';
import '../../features/history/history_view.dart';
import '../../features/scanner/scanner_view.dart';
import '../../features/scanner/detection_controller.dart';
import '../../features/result/result_view.dart';
import '../../data/models/detection_item.dart';
import '../../data/repositories/detection_repository.dart';

GoRouter createAppRouter({required bool isLoggedIn}) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashView(),
      ),
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
      GoRoute(
        path: AppRoutes.scanner,
        builder: (context, state) => ScannerView(
          controller: DetectionController(
            repository: DetectionRepository(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.result,
        builder: (context, state) {
          final detections = state.extra as List<DetectionItem>;
          return ResultView(detections: detections);
        },
      ),
    ],
  );
}

class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const history = '/history';
  static const scanner = '/scanner';
  static const result = '/result';
}
