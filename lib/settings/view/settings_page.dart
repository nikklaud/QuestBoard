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
  Future<void> _confirmAccountDeletion(String nickname) async {
    final controller = TextEditingController();
    String? validationError;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          icon: Icon(
            Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.error,
          ),
          title: const Text('Delete account?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This permanently deletes your account and profile. This action cannot be undone.',
              ),
              const SizedBox(height: 16),
              Text('Type “$nickname” to confirm.'),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Your nickname',
                  errorText: validationError,
                ),
                onSubmitted: (_) {
                  if (controller.text.trim() == nickname) {
                    Navigator.of(dialogContext).pop(true);
                  } else {
                    setDialogState(
                      () => validationError = 'Nickname does not match',
                    );
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () {
                if (controller.text.trim() == nickname) {
                  Navigator.of(dialogContext).pop(true);
                } else {
                  setDialogState(
                    () => validationError = 'Nickname does not match',
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();

    if (confirmed == true && mounted) {
      context.read<AuthBloc>().add(DeleteAccountRequest(nickname: nickname));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme =
        context.watch<ThemeCubit>().state.brightness == Brightness.dark;
    final authState = context.watch<AuthBloc>().state;
    final nickname = authState is AuthAuthenticated
        ? authState.user.nickname
        : null;
    return BlocListener<AuthBloc, AuthBlocState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          GetIt.I<Talker>().debug(
            'Navigating to login (state: ${state.runtimeType})',
          );
          context.goNamed('login');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
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
                      const Icon(Icons.logout_outlined),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          'Logout',
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      FilledButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(LogoutRequest());
                        },
                        child: const Icon(Icons.logout_outlined),
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
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_forever_outlined,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          'Delete account',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                        ),
                        onPressed: nickname == null
                            ? null
                            : () => _confirmAccountDeletion(nickname),
                        child: const Icon(Icons.delete_outline),
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
                      const Icon(Icons.dark_mode_outlined),
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
                      const Icon(Icons.language_outlined),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          'Language',
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      PopupMenuButton(
                        icon: const Icon(Icons.keyboard_arrow_down_outlined),
                        itemBuilder: (context) => [
                          const PopupMenuItem(child: Text('English')),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
