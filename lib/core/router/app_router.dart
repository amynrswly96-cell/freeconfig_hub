import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/about/presentation/about_screen.dart';
import '../../features/connection/presentation/connection_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/my_servers/presentation/add_server_screen.dart';
import '../../features/my_servers/presentation/my_servers_screen.dart';
import '../../features/my_servers/presentation/qr_scan_screen.dart';
import '../../features/servers/domain/models/server_model.dart';
import '../../features/servers/presentation/categories_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../widgets/root_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => RootShell(
          location: state.uri.toString(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/categories',
            builder: (context, state) => const CategoriesScreen(),
          ),
          GoRoute(
            path: '/my-servers',
            builder: (context, state) => const MyServersScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => AddServerScreen(
                  editingServer: state.extra as ServerModel?,
                ),
              ),
              GoRoute(
                path: 'scan',
                builder: (context, state) => const QrScanScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/about',
            builder: (context, state) => const AboutScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/connection',
        builder: (context, state) => const ConnectionScreen(),
      ),
    ],
  );
});
