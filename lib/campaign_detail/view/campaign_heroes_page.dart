import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:quest_board/auth/data/repo/abstract_auth_repo.dart';
import 'package:quest_board/campaign_detail/cubit/campaign_detail_cubit.dart';
import 'package:quest_board/campaign_detail/view/widgets/create_hero_sheet.dart';
import 'package:quest_board/campaign_list/data/model/campaign.dart';

class CampaignHeroesPage extends StatefulWidget {
  const CampaignHeroesPage({
    super.key,
    required this.campaignId,
    required this.currentUserId,
  });

  final String campaignId;
  final String currentUserId;

  @override
  State<CampaignHeroesPage> createState() => _CampaignHeroesPageState();
}

class _CampaignHeroesPageState extends State<CampaignHeroesPage> {
  late final CampaignDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = CampaignDetailCubit(
      campaignId: widget.campaignId,
      currentUserId: widget.currentUserId,
    )..loadCampaign();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<Map<String, String>> getPlayerNicknames(List<String> playerIds) async {
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

  void showCreateHeroSheet(BuildContext context, Campaign campaign) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CreateHeroSheet(campaign: campaign),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<CampaignDetailCubit, CampaignDetailState>(
        builder: (context, state) {
          final bool isLoading = state.status == CampaignDetailStatus.loading;
          final bool isError = state.status == CampaignDetailStatus.error;
          final bool isLoaded = state.status == CampaignDetailStatus.loaded;
          final Campaign? campaign = state.campaign;

          return Scaffold(
            appBar: AppBar(
              title: Text(campaign?.worldName ?? 'Heroes'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/'),
              ),
              actions: [
                if (isLoaded && campaign != null)
                  IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: () =>
                        context.go('/campaign/${widget.campaignId}/calendar'),
                  ),
              ],
            ),
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : isError
                ? Center(child: Text(state.errorMessage ?? 'Error'))
                : !isLoaded || campaign == null
                ? const SizedBox.shrink()
                : buildHeroesView(context, state),
            floatingActionButton: isLoaded && state.isOwner
                ? FloatingActionButton(
                    onPressed: () {
                      if (campaign != null) {
                        showCreateHeroSheet(context, campaign);
                      }
                    },
                    child: const Icon(Icons.add),
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget buildHeroesView(BuildContext context, CampaignDetailState state) {
    final heroes = state.heroes;

    return FutureBuilder<Map<String, String>>(
      future: getPlayerNicknames(state.campaign!.playerIds),
      builder: (context, snapshot) {
        final nicknames = snapshot.data ?? {};
        if (heroes.isEmpty) {
          return const Center(child: Text('No heroes yet'));
        }
        return ListView.builder(
          itemCount: heroes.length,
          itemBuilder: (context, index) {
            final hero = heroes[index];
            final playerNickname =
                nicknames[hero.playerId] ?? 'Player not found';
            return ListTile(
              title: Text(hero.name),
              subtitle: Text(playerNickname),
            );
          },
        );
      },
    );
  }
}
