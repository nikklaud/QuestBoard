import 'package:go_router/go_router.dart';
import 'package:quest_board/auth/view/login_page.dart';
import 'package:quest_board/auth/view/registration_page.dart';
import 'package:quest_board/campaign_list/view/campaign_list_page.dart';

final GoRouter runtimeRouter = GoRouter(
  initialLocation: '/login',
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
  ],
);
