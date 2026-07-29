import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:quest_board/campaign_list/data/model/campaign.dart';
import 'package:quest_board/campaign_list/data/repo/abstract_campaign_repo.dart';
import 'package:talker_flutter/talker_flutter.dart';

part 'campaign_list_state.dart';

class CampaignListCubit extends Cubit<CampaignListState> {
  CampaignListCubit() : super(CampaignListInitial());

  Future<void> loadCampaigns(String userId) async {
    emit(CampaignListLoading());
    try {
      final campaignRepo = GetIt.I<AbstractCampaignRepo>();

      final owned = await campaignRepo.getCampaignsByOwner(userId);
      final joined = await campaignRepo.getCampaignsByPlayer(userId);

      emit(CampaignListLoaded(ownedCampaigns: owned, joinedCampaigns: joined));
    } catch (e) {
      GetIt.I<Talker>().error('Error loading campaigns: $e');
      emit(CampaignListError(e.toString()));
    }
  }

  void refresh(String userId) async {
    await loadCampaigns(userId);
  }
}
