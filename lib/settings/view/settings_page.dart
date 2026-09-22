import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quest_board/auth/bloc/auth_bloc.dart';
import 'package:quest_board/settings/cubit/theme_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> _confirmAccountDeletion(String nickname) async {
    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (_) => _DeleteAccountDialog(nickname: nickname),
    );

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
        if (state is AuthFailure && context.mounted) {
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

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.nickname});

  final String nickname;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  late final TextEditingController _controller;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (_controller.text.trim() == widget.nickname) {
      Navigator.of(context, rootNavigator: true).pop(true);
    } else {
      setState(() => _validationError = 'Nickname does not match');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: Theme.of(context).colorScheme.error,
      ),
      title: const Text('Delete account?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This permanently deletes your account and profile. This action cannot be undone.',
            ),
            const SizedBox(height: 16),
            Text('Type "${widget.nickname}" to confirm.'),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Your nickname',
                errorText: _validationError,
              ),
              onChanged: (_) {
                if (_validationError != null) {
                  setState(() => _validationError = null);
                }
              },
              onSubmitted: (_) => _onConfirm(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context, rootNavigator: true).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: _onConfirm,
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
