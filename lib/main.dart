import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:quest_board/auth/bloc/auth_bloc.dart';
import 'package:quest_board/auth/data/repo/abstract_auth_repo.dart';
import 'package:quest_board/auth/data/repo/auth_repo.dart';
import 'package:quest_board/firebase_options.dart';
import 'package:quest_board/router.dart';
import 'package:talker_flutter/talker_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final talker = TalkerFlutter.init();
  GetIt.I.registerLazySingleton<AbstractAuthRepo>(() => AuthRepo());
  GetIt.I.registerLazySingleton(() => talker);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(CheckAuthStatusRequest())),
      ],
      child: MaterialApp.router(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: .fromSeed(
            seedColor: const Color(0xFFFFA18C),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        routerConfig: runtimeRouter,
      ),
    );
  }
}
