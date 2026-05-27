import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:quest_board/auth/bloc/auth_bloc.dart';
import 'package:quest_board/settings/cubit/theme_cubit.dart';
import 'package:talker_flutter/talker_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme =
        context.watch<ThemeCubit>().state.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                height: 65,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.logout_outlined),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text('Logout', style: theme.textTheme.titleLarge),
                    ),
                    BlocListener<AuthBloc, AuthBlocState>(
                      listener: (context, state) {
                        if (state is AuthUnauthenticated) {
                          GetIt.I<Talker>().debug('Logout');
                          context.goNamed('login');
                        }
                      },
                      child: FilledButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(LogoutRequest());
                        },
                        child: Icon(Icons.logout_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Container(
                height: 65,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.dark_mode_outlined),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        'Dark theme',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    Switch(
                      value: isDarkTheme,
                      onChanged: (value) {
                        context.read<ThemeCubit>().setThemeBrightness(
                          value ? Brightness.dark : Brightness.light,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Container(
                height: 65,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.language_outlined),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        'Language',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    PopupMenuButton(
                      icon: Icon(Icons.keyboard_arrow_down_outlined),
                      itemBuilder: (context) => [
                        PopupMenuItem(child: Text('English')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
