import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/design_system/presentation/design_system_showcase_screen.dart';

/// RxEdge App Router Configuration
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'design-showcase',
      builder: (BuildContext context, GoRouterState state) {
        return const DesignSystemShowcaseScreen();
      },
    ),
  ],
);
