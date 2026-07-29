import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:quest_board/auth/data/repo/abstract_auth_repo.dart';
import 'package:quest_board/campaign_detail/cubit/campaign_detail_cubit.dart';
import 'package:quest_board/campaign_detail/data/model/hero.dart';
import 'package:quest_board/campaign_detail/data/model/quest.dart';
import 'package:quest_board/campaign_detail/view/widgets/calendar_surface.dart';
import 'package:quest_board/campaign_detail/view/widgets/create_quest_sheet.dart';
import 'package:quest_board/campaign_detail/view/widgets/quest_list_tile.dart';
import 'package:quest_board/campaign_detail/view/widgets/quest_preview_card.dart';
import 'package:quest_board/campaign_list/data/model/campaign.dart';
import 'package:quest_board/campaign_list/data/model/custom_month.dart';

class CampaignCalendarPage extends StatefulWidget {
  const CampaignCalendarPage({
    super.key,
    required this.campaignId,
    required this.currentUserId,
  });

  final String campaignId;
  final String currentUserId;

  @override
  State<CampaignCalendarPage> createState() => _CampaignCalendarPageState();
}

class _CampaignCalendarPageState extends State<CampaignCalendarPage> {
  late final CampaignDetailCubit _cubit;
  int _currentMonthIndex = 0;

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

  int computeMonthOffset(
    List<CustomMonth> sortedMonths,
    int monthIndex,
    int daysOfWeekLength,
  ) {
    if (daysOfWeekLength == 0) return 0;
    int offset = 0;
    for (int i = 0; i < monthIndex; i++) {
      offset = (offset + sortedMonths[i].daysCount) % daysOfWeekLength;
    }
    return offset;
  }

  List<Quest> questsForMonth(List<Quest> quests, int monthIndex) {
    final monthQuests = quests.where((quest) {
      return quest.startMonthIndex <= monthIndex &&
          quest.endMonthIndex >= monthIndex;
    }).toList();

    monthQuests.sort((left, right) {
      final startCompare = left.startDayNumber.compareTo(right.startDayNumber);
      if (startCompare != 0) {
        return startCompare;
      }

      return left.title.compareTo(right.title);
    });

    return monthQuests;
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

  void showQuestsBottomSheet(BuildContext context, int day, Campaign campaign) {
    final quests = _cubit.state.questsByCell['$_currentMonthIndex-$day'] ?? [];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        if (quests.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('No quests on this day')),
          );
        }

        return SizedBox(
          height: 400,
          child: ListView.builder(
            itemCount: quests.length,
            itemBuilder: (context, index) =>
                QuestListTile(quest: quests[index], campaign: campaign),
          ),
        );
      },
    );
  }

  void showCreateQuestSheet(
    BuildContext context,
    List<CampaignHero> heroes,
    List<CustomMonth> months,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CreateQuestSheet(heroes: heroes, months: months),
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
              title: Text(campaign?.worldName ?? 'Calendar'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/'),
              ),
              actions: [
                if (isLoaded && campaign != null)
                  IconButton(
                    icon: const Icon(Icons.people),
                    onPressed: () =>
                        context.go('/campaign/${widget.campaignId}/heroes'),
                  ),
              ],
            ),
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : isError
                ? Center(child: Text(state.errorMessage ?? 'Error'))
                : !isLoaded || campaign == null
                ? const SizedBox.shrink()
                : buildCalendarView(context, state, campaign),
            floatingActionButton: isLoaded && state.isOwner
                ? FloatingActionButton(
                    onPressed: () {
                      if (campaign != null) {
                        showCreateQuestSheet(
                          context,
                          state.heroes,
                          campaign.months,
                        );
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

  Widget buildCalendarView(
    BuildContext context,
    CampaignDetailState state,
    Campaign campaign,
  ) {
    final sortedMonths = List<CustomMonth>.from(campaign.months)
      ..sort((a, b) => a.order.compareTo(b.order));

    if (sortedMonths.isEmpty) {
      return const Center(
        child: Text('No months configured for this campaign'),
      );
    }

    if (_currentMonthIndex >= sortedMonths.length) {
      _currentMonthIndex = sortedMonths.length - 1;
    }
    if (_currentMonthIndex < 0) {
      _currentMonthIndex = 0;
    }

    final currentMonth = sortedMonths[_currentMonthIndex];
    final currentMonthQuests = questsForMonth(state.quests, _currentMonthIndex);

    final offset = computeMonthOffset(
      sortedMonths,
      _currentMonthIndex,
      campaign.daysOfWeek.length,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        CalendarSurface(
          month: currentMonth,
          daysOfWeek: campaign.daysOfWeek,
          questsByCell: state.questsByCell,
          monthOffset: offset,
          monthIndex: _currentMonthIndex,
          onPrevious: _currentMonthIndex > 0
              ? () => setState(() => _currentMonthIndex--)
              : null,
          onNext: _currentMonthIndex < sortedMonths.length - 1
              ? () => setState(() => _currentMonthIndex++)
              : null,
          onCellTap: (day) => showQuestsBottomSheet(context, day, campaign),
        ),
        const SizedBox(height: 20),
        QuestPreviewSection(campaign: campaign, quests: currentMonthQuests),
      ],
    );
  }
}
