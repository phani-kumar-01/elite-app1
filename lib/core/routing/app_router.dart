import 'package:go_router/go_router.dart';

import '../../state/app_state.dart';
import '../../ui/auth/login_screen.dart';
import '../../ui/student/student_main_navigation.dart';
import '../../ui/staff/staff_main_navigation.dart';
import '../../ui/admin/admin_main_navigation.dart';

class AppRouter {
  static GoRouter createRouter(AppState appState) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: appState,
      redirect: (context, state) {
        final isLoading = appState.isLoadingFromSupabase;
        final isLoggedIn = appState.isLoggedIn;

        // While fetching data, don't redirect — let loading handle itself
        if (isLoading) return null;

        final isOnLogin = state.matchedLocation == '/login';

        // Not logged in → always go to login
        if (!isLoggedIn && !isOnLogin) return '/login';

        // Already logged in → go to appropriate dashboard
        if (isLoggedIn && isOnLogin) {
          if (appState.isAdmin) return '/admin';
          if (appState.isStaff) return '/staff';
          return '/student';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/student',
          builder: (context, state) => const StudentMainNavigation(),
        ),
        GoRoute(
          path: '/staff',
          builder: (context, state) => const StaffMainNavigation(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminMainNavigation(),
        ),
      ],
    );
  }
}
