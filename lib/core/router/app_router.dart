import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/map/presentation/pages/map_page.dart';
import '../../features/map/presentation/pages/shop_detail_page.dart';
import '../../features/services/presentation/pages/request_service_page.dart';
import '../../features/services/presentation/pages/pro_dashboard_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/map/presentation/bloc/map_bloc.dart';
import '../../features/services/presentation/bloc/service_bloc.dart';
import '../di/service_locator.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<AuthBloc>(),
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<AuthBloc>(),
          child: const RegisterPage(),
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<MapBloc>(),
          child: const MapPage(),
        ),
      ),
      GoRoute(
        path: '/shop/:shopId',
        builder: (context, state) {
          final shopId = state.pathParameters['shopId']!;
          return ShopDetailPage(shopId: shopId);
        },
      ),
      GoRoute(
        path: '/request-service',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<ServiceBloc>(),
          child: const RequestServicePage(),
        ),
      ),
      GoRoute(
        path: '/pro-dashboard',
        builder: (context, state) => const ProDashboardPage(),
      ),
    ],
  );
}
