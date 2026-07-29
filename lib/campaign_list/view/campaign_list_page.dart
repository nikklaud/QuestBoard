import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:quest_board/auth/bloc/auth_bloc.dart';
import 'package:quest_board/campaign_list/cubit/campaign_list_cubit.dart';
import 'package:quest_board/campaign_list/cubit/create_campaign_cubit.dart';
import 'package:quest_board/campaign_list/cubit/join_campaign_cubit.dart';
import 'package:quest_board/campaign_list/data/model/campaign.dart';
import 'package:quest_board/campaign_list/data/repo/abstract_campaign_repo.dart';
import 'package:quest_board/campaign_list/view/create_campaign_bottom_sheet.dart';
import 'package:quest_board/campaign_list/view/invite_campaign_sheet.dart';
import 'package:quest_board/campaign_list/view/widgets/campaign_card.dart';
import 'package:quest_board/campaign_list/view/widgets/campaign_edit_sheet.dart';
import 'package:quest_board/campaign_list/view/widgets/empty_state.dart';
import 'package:talker_flutter/talker_flutter.dart';

class CampaignListPage extends StatefulWidget {
  const CampaignListPage({super.key});

  @override
  State<CampaignListPage> createState() => _CampaignListPageState();
}

class _CampaignListPageState extends State<CampaignListPage> {
  late CampaignListCubit _campaignListCubit;
  String? _lastLoadedUserId;

  @override
  void initState() {
    super.initState();
    _campaignListCubit = CampaignListCubit();
  }

  void _loadCampaigns(String userId) {
    if (_lastLoadedUserId != userId) {
      _lastLoadedUserId = userId;
      _campaignListCubit.loadCampaigns(userId);
    }
  }

  void _refreshCampaigns() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _campaignListCubit.refresh(authState.user.id);
    }
  }

  void _onCreateCampaignPressed() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      showModalBottomSheet(
        showDragHandle: true,
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => CreateCampaignCubit(ownerId: authState.user.id),
            ),
            BlocProvider(
              create: (_) =>
                  JoinCampaignCubit(currentUserId: authState.user.id),
            ),
          ],
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: CreateCampaignBottomSheet(userId: authState.user.id),
            ),
          ),
        ),
      );
    }
  }

  Future<Map<String, String>> _getPlayerNicknames(Campaign campaign) async {
    final nicknames = <String, String>{};
    final firestore = FirebaseFirestore.instance;

    try {
      final ownerDoc = await firestore
          .collection('users')
          .doc(campaign.ownerId)
          .get();
      if (ownerDoc.exists) {
        nicknames[campaign.ownerId] = ownerDoc['nickname'] ?? 'Unknown';
      }
    } catch (_) {}

    for (final playerId in campaign.playerIds) {
      try {
        final playerDoc = await firestore
            .collection('users')
            .doc(playerId)
            .get();
        if (playerDoc.exists) {
          nicknames[playerId] = playerDoc['nickname'] ?? 'Unknown';
        }
      } catch (_) {}
    }

    return nicknames;
  }

  Future<void> _removePlayerFromCampaign(
    Campaign campaign,
    String playerId,
  ) async {
    try {
      final updatedCampaign = Campaign(
        id: campaign.id,
        campaignName: campaign.campaignName,
        worldName: campaign.worldName,
        ownerId: campaign.ownerId,
        inviteCode: campaign.inviteCode,
        daysOfWeek: campaign.daysOfWeek,
        months: campaign.months,
        playerIds: campaign.playerIds.where((id) => id != playerId).toList(),
        createdAt: campaign.createdAt,
        updatedAt: DateTime.now(),
      );
      await GetIt.I<AbstractCampaignRepo>().updateCampaign(updatedCampaign);

      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        _campaignListCubit.refresh(authState.user.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Player removed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _deleteCampaign(Campaign campaign) async {
    try {
      await GetIt.I<AbstractCampaignRepo>().deleteCampaign(campaign.id);
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        _campaignListCubit.refresh(authState.user.id);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Campaign deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting campaign: $e')));
      }
    }
  }

  void _showEditCampaignSheet(Campaign campaign) {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CampaignEditSheet(
        campaign: campaign,
        onSaved: _refreshCampaigns,
        onDelete: () => _deleteCampaign(campaign),
      ),
    );
  }

  @override
  void dispose() {
    _campaignListCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<AuthBloc, AuthBlocState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _loadCampaigns(state.user.id);
        } else if (state is AuthUnauthenticated) {
          _lastLoadedUserId = null;
        }
        if (state is AuthFailure) {
          GetIt.I<Talker>().error(
            'Auth failure, navigating to login: ${state.message}',
          );
          context.goNamed('login');
        }
      },
      child: BlocBuilder<AuthBloc, AuthBlocState>(
        builder: (context, authState) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Quest Board', textAlign: TextAlign.center),
              actions: [
                IconButton(
                  onPressed: () {
                    context.pushNamed('settings');
                  },
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: 'Settings',
                ),
              ],
            ),
            body: authState is AuthAuthenticated
                ? BlocProvider<CampaignListCubit>.value(
                    value: _campaignListCubit,
                    child: BlocBuilder<CampaignListCubit, CampaignListState>(
                      builder: (context, state) {
                        if (state is CampaignListLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state is CampaignListError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Error: ${state.message}'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _refreshCampaigns,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (state is CampaignListLoaded) {
                          if (state.ownedCampaigns.isEmpty &&
                              state.joinedCampaigns.isEmpty) {
                            return EmptyState(
                              onCreateCampaign: _onCreateCampaignPressed,
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: () async {
                              _refreshCampaigns();
                            },
                            child: ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                Text(
                                  'My Campaigns',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (state.ownedCampaigns.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 32,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'No campaigns created yet',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ),
                                  )
                                else
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: state.ownedCampaigns.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final campaign =
                                          state.ownedCampaigns[index];
                                      return FutureBuilder<Map<String, String>>(
                                        future: _getPlayerNicknames(campaign),
                                        builder: (context, snapshot) {
                                          return CampaignCard(
                                            campaign: campaign,
                                            isOwner: true,
                                            playerNicknames:
                                                snapshot.data ?? {},
                                            onRemovePlayer: (playerId) =>
                                                _removePlayerFromCampaign(
                                                  campaign,
                                                  playerId,
                                                ),
                                            onEdit: () {
                                              _showEditCampaignSheet(campaign);
                                            },
                                            onInvite: () {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                backgroundColor:
                                                    Colors.transparent,
                                                builder: (context) =>
                                                    InviteCampaignSheet(
                                                      campaign: campaign,
                                                    ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                const SizedBox(height: 32),
                                Text(
                                  'Joined Campaigns',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (state.joinedCampaigns.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 32,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'You haven\'t joined any campaigns',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ),
                                  )
                                else
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: state.joinedCampaigns.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final campaign =
                                          state.joinedCampaigns[index];
                                      return FutureBuilder<Map<String, String>>(
                                        future: _getPlayerNicknames(campaign),
                                        builder: (context, snapshot) {
                                          return CampaignCard(
                                            campaign: campaign,
                                            isOwner: false,
                                            playerNicknames:
                                                snapshot.data ?? {},
                                          );
                                        },
                                      );
                                    },
                                  ),
                              ],
                            ),
                          );
                        }

                        return const Center(child: Text('Loading...'));
                      },
                    ),
                  )
                : const Center(child: Text('Please log in to view campaigns')),
            floatingActionButton: FloatingActionButton(
              onPressed: _onCreateCampaignPressed,
              tooltip: 'Create Campaign',
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
