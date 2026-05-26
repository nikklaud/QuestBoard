import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:quest_board/auth/data/repo/abstract_auth_repo.dart';
import 'package:quest_board/auth/view/login_page.dart';
import 'package:quest_board/auth/view/registration_page.dart';
import 'package:talker_flutter/talker_flutter.dart';

void main() {
  final talker = TalkerFlutter.init();
  GetIt.I.registerLazySingleton(() => AbstractAuthRepo);
  GetIt.I.registerLazySingleton(() => talker);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: const Color(0xFFFFA18C),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const RegistrationPage(),
    );
  }
}
