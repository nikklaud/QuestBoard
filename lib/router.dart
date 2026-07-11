import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quest_board/auth/bloc/auth_bloc.dart';
import 'package:quest_board/auth/view/login_page.dart';
import 'package:quest_board/auth/view/registration_page.dart';
import 'package:quest_board/campaign_list/view/campaign_list_page.dart';
import 'package:quest_board/settings/view/settings_page.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthBlocState> stream) {
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthBlocState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter? _router;

GoRouter getRouter({required AuthBloc authBloc}) {
  _router ??= GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoading = authState is AuthLoading || authState is AuthBlocInitial;
      final loggedIn = authState is AuthAuthenticated;
      final loggingIn =
          state.uri.path == '/login' || state.uri.path == '/registration';

      if (isLoading) {
        return null;
      }

      if (!loggedIn && !loggingIn) {
        return '/login';
      }

      if (loggedIn && loggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'campaign_list',
        builder: (context, state) => const CampaignListPage(),
      ),
      GoRoute(
        path: '/registration',
        name: 'registration',
        builder: (context, state) => const RegistrationPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
  return _router!;
}