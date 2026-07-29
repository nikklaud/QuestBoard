import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:quest_board/campaign_detail/data/model/hero.dart';
import 'package:quest_board/campaign_detail/data/model/quest.dart';
import 'package:quest_board/campaign_detail/data/repo/abstract_hero_repo.dart';
import 'package:quest_board/campaign_detail/data/repo/abstract_quest_repo.dart';
import 'package:quest_board/campaign_list/data/model/campaign.dart';
import 'package:quest_board/campaign_list/data/model/custom_month.dart';
import 'package:quest_board/campaign_list/data/repo/abstract_campaign_repo.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:uuid/uuid.dart';

part 'campaign_detail_state.dart';

class CampaignDetailCubit extends Cubit<CampaignDetailState> {
  CampaignDetailCubit({
    required String campaignId,
    required String currentUserId,
  }) : super(const CampaignDetailState()) {
    _campaignId = campaignId;
    _currentUserId = currentUserId;
  }

  late final String _campaignId;
  late final String _currentUserId;

  Future<void> loadCampaign() async {
    emit(state.copyWith(status: CampaignDetailStatus.loading));

    try {
      final campaignRepo = GetIt.I<AbstractCampaignRepo>();
      final questRepo = GetIt.I<AbstractQuestRepo>();
      final heroRepo = GetIt.I<AbstractHeroRepo>();

      final campaign = await campaignRepo.getCampaignById(_campaignId);
      if (campaign == null) {
        emit(
          state.copyWith(
            status: CampaignDetailStatus.error,
            errorMessage: 'Campaign not found',
          ),
        );
        return;
      }

      List<Quest> quests = [];
      List<CampaignHero> heroes = [];

      try {
        quests = await questRepo.getQuestsByCampaign(_campaignId);
      } catch (e) {
        GetIt.I<Talker>().error('Failed to load quests: $e');
      }

      try {
        heroes = await heroRepo.getHeroesByCampaign(_campaignId);
      } catch (e) {
        GetIt.I<Talker>().error('Failed to load heroes: $e');
      }

      final isOwner = campaign.ownerId == _currentUserId;

      final questsByCell = _computeQuestsByCell(quests, campaign.months);

      emit(
        state.copyWith(
          status: CampaignDetailStatus.loaded,
          campaign: campaign,
          quests: quests,
          heroes: heroes,
          isOwner: isOwner,
          questsByCell: questsByCell,
        ),
      );

      GetIt.I<Talker>().debug(
        'Campaign loaded: ${campaign.campaignName}, quests: ${quests.length}, heroes: ${heroes.length}',
      );
    } catch (e) {
      GetIt.I<Talker>().error('Error loading campaign: $e');
      if (!isClosed) {
        emit(
          state.copyWith(
            status: CampaignDetailStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    }
  }

  Map<String, List<Quest>> _computeQuestsByCell(
    List<Quest> quests,
    List<CustomMonth> months,
  ) {
    final Map<String, List<Quest>> questsByCell = {};
    for (final quest in quests) {
      for (var m = quest.startMonthIndex; m <= quest.endMonthIndex; m++) {
        final monthDays = m < months.length ? months[m].daysCount : 30;
        final dayStart = m == quest.startMonthIndex ? quest.startDayNumber : 1;
        final dayEnd = m == quest.endMonthIndex
            ? quest.endDayNumber
            : monthDays;
        for (var d = dayStart; d <= dayEnd; d++) {
          final key = '$m-$d';
          questsByCell.putIfAbsent(key, () => []).add(quest);
        }
      }
    }
    return questsByCell;
  }

  Future<void> createQuest({
    required String title,
    required String description,
    required int startMonthIndex,
    required int startDayNumber,
    required int endMonthIndex,
    required int endDayNumber,
    required List<String> heroIds,
  }) async {
    if (!state.isOwner) return;

    try {
      final questRepo = GetIt.I<AbstractQuestRepo>();
      final quest = Quest(
        id: const Uuid().v4(),
        campaignId: _campaignId,
        title: title,
        description: description,
        color: _randomColor(),
        startMonthIndex: startMonthIndex,
        startDayNumber: startDayNumber,
        endMonthIndex: endMonthIndex,
        endDayNumber: endDayNumber,
        heroIds: heroIds,
        createdAt: DateTime.now(),
      );

      await questRepo.createQuest(quest);
      await loadCampaign();
    } catch (e) {
      GetIt.I<Talker>().error('Error creating quest: $e');
    }
  }

  Future<void> createHero({
    required String name,
    required String playerId,
  }) async {
    if (!state.isOwner) return;

    try {
      final heroRepo = GetIt.I<AbstractHeroRepo>();
      final hero = CampaignHero(
        id: const Uuid().v4(),
        campaignId: _campaignId,
        name: name,
        playerId: playerId,
        createdAt: DateTime.now(),
      );

      await heroRepo.createHero(hero);
      await loadCampaign();
    } catch (e) {
      GetIt.I<Talker>().error('Error creating hero: $e');
    }
  }

  String _randomColor() {
    final colors = [
      '#FF6B6B',
      '#4ECDC4',
      '#45B7D1',
      '#96CEB4',
      '#FFEAA7',
      '#DDA0DD',
      '#98D8C8',
      '#F7DC6F',
      '#BB8FCE',
      '#85C1E9',
    ];
    return colors[DateTime.now().millisecond % colors.length];
  }

  Future<void> updateCampaign({
    required String campaignId,
    required String campaignName,
    required String worldName,
  }) async {
    if (!state.isOwner) return;

    final campaign = state.campaign;
    if (campaign == null) return;

    try {
      final campaignRepo = GetIt.I<AbstractCampaignRepo>();
      final updatedCampaign = campaign.copyWith(
        campaignName: campaignName,
        worldName: worldName,
        updatedAt: DateTime.now(),
      );
      await campaignRepo.updateCampaign(updatedCampaign);
      await loadCampaign();
    } catch (e) {
      GetIt.I<Talker>().error('Error updating campaign: $e');
    }
  }
}
