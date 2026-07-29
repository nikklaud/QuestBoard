import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:quest_board/auth/data/repo/abstract_auth_repo.dart';
import 'package:quest_board/campaign_list/data/repo/abstract_campaign_repo.dart';
import 'package:talker_flutter/talker_flutter.dart';

part 'join_campaign_state.dart';

class JoinCampaignCubit extends Cubit<JoinCampaignState> {
  JoinCampaignCubit({required this._currentUserId})
    : super(const JoinCampaignState());

  final String _currentUserId;

  void updateInviteCode(String code) {
    emit(state.copyWith(inviteCode: code.toUpperCase()));
  }

  Future<void> joinByInviteCode() async {
    if (state.inviteCode.isEmpty) {
      emit(
        state.copyWith(
          status: JoinStatus.error,
          errorMessage: 'Please enter an invitation code',
        ),
      );
      return;
    }

    emit(state.copyWith(status: JoinStatus.loading));

    try {
      final campaignRepo = GetIt.I<AbstractCampaignRepo>();
      final authRepo = GetIt.I<AbstractAuthRepo>();

      final campaign = await campaignRepo.getCampaignByInviteCode(
        state.inviteCode,
      );

      if (campaign == null) {
        emit(
          state.copyWith(
            status: JoinStatus.error,
            errorMessage:
                'Campaign not found. Please check the invitation code.',
          ),
        );
        return;
      }

      if (campaign.ownerId == _currentUserId) {
        emit(
          state.copyWith(
            status: JoinStatus.error,
            errorMessage: 'You are the owner of this campaign.',
          ),
        );
        return;
      }

      if (campaign.playerIds.contains(_currentUserId)) {
        emit(
          state.copyWith(
            status: JoinStatus.error,
            errorMessage: 'You are already a participant of this campaign.',
          ),
        );
        return;
      }

      await campaignRepo.joinCampaign(campaign.id, _currentUserId);

      final currentUser = await authRepo.getCurrentUser();
      if (currentUser != null) {
        final updatedCampaignIds = [
          ...currentUser.joinedCampaignIds,
          campaign.id,
        ];
        await authRepo.updateUserJoinedCampaigns(
          currentUser.id,
          updatedCampaignIds,
        );
      }

      GetIt.I<Talker>().debug(
        'Successfully joined campaign: ${campaign.campaignName}',
      );
      emit(
        state.copyWith(
          status: JoinStatus.success,
          campaignName: campaign.campaignName,
        ),
      );
    } catch (e) {
      GetIt.I<Talker>().error('Error joining campaign: $e');
      emit(
        state.copyWith(status: JoinStatus.error, errorMessage: e.toString()),
      );
    }
  }

  void reset() {
    emit(const JoinCampaignState());
  }
}
