import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:quest_board/auth/data/repo/abstract_auth_repo.dart';
import 'package:quest_board/campaign_detail/cubit/campaign_detail_cubit.dart';
import 'package:quest_board/campaign_list/data/model/campaign.dart';

class CreateHeroSheet extends StatefulWidget {
  const CreateHeroSheet({required this.campaign});

  final Campaign campaign;

  @override
  State<CreateHeroSheet> createState() => _CreateHeroSheetState();
}

class _CreateHeroSheetState extends State<CreateHeroSheet> {
  final _nameController = TextEditingController();
  String? _selectedPlayerId;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Hero Name'),
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, String>>(
              future: _getPlayerNicknames(widget.campaign.playerIds),
              builder: (context, snapshot) {
                final playerOptions = snapshot.data ?? {};
                return DropdownButtonFormField<String>(
                  initialValue: _selectedPlayerId,
                  hint: const Text('Select Player'),
                  decoration: const InputDecoration(labelText: 'Player'),
                  items: playerOptions.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPlayerId = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed:
                  _selectedPlayerId == null || _nameController.text.isEmpty
                  ? null
                  : () {
                      context.read<CampaignDetailCubit>().createHero(
                        name: _nameController.text.trim(),
                        playerId: _selectedPlayerId!,
                      );
                      Navigator.pop(context);
                    },
              child: const Text('Create Hero'),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, String>> _getPlayerNicknames(
    List<String> playerIds,
  ) async {
    final nicknames = <String, String>{};
    final authRepo = GetIt.I<AbstractAuthRepo>();

    for (final playerId in playerIds) {
      try {
        final user = await authRepo.getUserById(playerId);
        if (user != null) {
          nicknames[playerId] = user.nickname;
        }
      } catch (_) {}
    }

    return nicknames;
  }
}
