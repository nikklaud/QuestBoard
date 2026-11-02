import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:quest_board/auth/bloc/auth_bloc.dart';
import 'package:quest_board/auth/data/repo/abstract_auth_repo.dart';
import 'package:quest_board/auth/data/repo/auth_repo.dart';
import 'package:quest_board/campaign_detail/data/repo/abstract_hero_repo.dart';
import 'package:quest_board/campaign_detail/data/repo/abstract_quest_repo.dart';
import 'package:quest_board/campaign_detail/data/repo/hero_repo.dart';
import 'package:quest_board/campaign_detail/data/repo/quest_repo.dart';
import 'package:quest_board/campaign_list/data/repo/abstract_campaign_repo.dart';
import 'package:quest_board/campaign_list/data/repo/campaign_repo.dart';
import 'package:quest_board/firebase_options.dart';
import 'package:quest_board/router.dart';
import 'package:quest_board/settings/cubit/theme_cubit.dart';
import 'package:quest_board/settings/data/repo/abstract_settings_repo.dart';
import 'package:quest_board/settings/data/repo/settings_repo.dart';
import 'package:quest_board/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

late final AuthBloc authBloc;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  GetIt.I.registerLazySingleton<AbstractAuthRepo>(
    () => AuthRepo(
      firebaseAuth: FirebaseAuth.instance,
      firebaseFirestore: FirebaseFirestore.instance,
    ),
  );

  GetIt.I.registerLazySingleton<AbstractCampaignRepo>(
    () => CampaignRepo(firebaseFirestore: FirebaseFirestore.instance),
  );

  GetIt.I.registerLazySingleton<AbstractQuestRepo>(
    () => QuestRepo(firebaseFirestore: FirebaseFirestore.instance),
  );

  GetIt.I.registerLazySingleton<AbstractHeroRepo>(
    () => HeroRepo(firebaseFirestore: FirebaseFirestore.instance),
  );

  final SharedPreferences preferences = await SharedPreferences.getInstance();
  GetIt.I.registerSingleton<SharedPreferences>(preferences);

  GetIt.I.registerLazySingleton<AbstractSettingsRepo>(
    () => SettingsRepo(preferences: GetIt.I<SharedPreferences>()),
  );

  final talker = TalkerFlutter.init();
  GetIt.I.registerLazySingleton(() => talker);

  authBloc = AuthBloc();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider(
          create: (_) =>
              ThemeCubit(settingsRepo: GetIt.I<AbstractSettingsRepo>()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'QuestBoard',
            theme: state.brightness == Brightness.dark ? darkTheme : lightTheme,
            routerConfig: getRouter(authBloc: authBloc),
          );
        },
      ),
    );
  }
}
