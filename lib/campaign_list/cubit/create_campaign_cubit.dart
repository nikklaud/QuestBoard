import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:quest_board/campaign_list/data/model/campaign.dart';
import 'package:quest_board/campaign_list/data/model/custom_month.dart';
import 'package:quest_board/campaign_list/data/model/day_of_week.dart';
import 'package:quest_board/campaign_list/data/repo/abstract_campaign_repo.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:uuid/uuid.dart';

part 'create_campaign_state.dart';

class CreateCampaignCubit extends Cubit<CreateCampaignState> {
  CreateCampaignCubit({required String ownerId})
    : _ownerId = ownerId,
      super(const CreateCampaignState());

  final String _ownerId;

  void updateCampaignName(String name) {
    emit(state.copyWith(campaignName: name));
  }

  void updateWorldName(String name) {
    emit(state.copyWith(worldName: name));
  }

  void addMonth(String name, int daysCount) {
    if (daysCount > 128) {
      GetIt.I<Talker>().warning('Max 128 days per month exceeded');
      return;
    }
    final newMonth = CustomMonth(
      name: name,
      daysCount: daysCount,
      order: state.months.length,
    );
    final updatedMonths = [...state.months, newMonth];
    emit(state.copyWith(months: updatedMonths));
  }

  void updateMonth(int index, String name, int daysCount) {
    if (daysCount > 128) {
      GetIt.I<Talker>().warning('Max 128 days per month exceeded');
      return;
    }
    final updatedMonths = [...state.months];
    updatedMonths[index] = CustomMonth(
      name: name,
      daysCount: daysCount,
      order: index,
    );
    emit(state.copyWith(months: updatedMonths));
  }

  void removeMonth(int index) {
    final updatedMonths = [...state.months]..removeAt(index);
    emit(
      state.copyWith(
        months: updatedMonths
            .asMap()
            .entries
            .map((e) => e.value.copyWith(order: e.key))
            .toList(),
      ),
    );
  }

  void addDay(String name) {
    if (state.daysOfWeek.length >= 16) {
      GetIt.I<Talker>().warning('Max 16 days per week exceeded');
      return;
    }
    final newDay = DayOfWeek(name: name, order: state.daysOfWeek.length);
    final updatedDays = [...state.daysOfWeek, newDay];
    emit(state.copyWith(daysOfWeek: updatedDays));
  }

  void updateDay(int index, String name) {
    final updatedDays = [...state.daysOfWeek];
    updatedDays[index] = DayOfWeek(name: name, order: index);
    emit(state.copyWith(daysOfWeek: updatedDays));
  }

  void removeDay(int index) {
    final updatedDays = [...state.daysOfWeek]..removeAt(index);
    emit(
      state.copyWith(
        daysOfWeek: updatedDays
            .asMap()
            .entries
            .map((e) => e.value.copyWith(order: e.key))
            .toList(),
      ),
    );
  }

  Future<void> submit() async {
    if (state.campaignName.isEmpty || state.worldName.isEmpty) {
      emit(
        state.copyWith(
          status: CreateStatus.error,
          errorMessage: 'Campaign name and world name are required',
        ),
      );
      return;
    }
    if (state.months.isEmpty) {
      emit(
        state.copyWith(
          status: CreateStatus.error,
          errorMessage: 'At least one month required',
        ),
      );
      return;
    }
    if (state.daysOfWeek.isEmpty) {
      emit(
        state.copyWith(
          status: CreateStatus.error,
          errorMessage: 'At least one day of week required',
        ),
      );
      return;
    }
    if (state.daysOfWeek.length > 16) {
      emit(
        state.copyWith(
          status: CreateStatus.error,
          errorMessage: 'Max 16 days per week allowed',
        ),
      );
      return;
    }

    emit(state.copyWith(status: CreateStatus.loading));

    try {
      final campaign = Campaign(
        id: const Uuid().v4(),
        campaignName: state.campaignName,
        worldName: state.worldName,
        ownerId: _ownerId,
        inviteCode: _generateInviteCode(),
        daysOfWeek: state.daysOfWeek,
        months: state.months,
        createdAt: DateTime.now(),
      );

      await GetIt.I<AbstractCampaignRepo>().createCampaign(campaign);
      GetIt.I<Talker>().debug('Campaign created: ${campaign.campaignName}');
      emit(state.copyWith(status: CreateStatus.success));
    } catch (e) {
      GetIt.I<Talker>().error('Error creating campaign: $e');
      emit(
        state.copyWith(status: CreateStatus.error, errorMessage: e.toString()),
      );
    }
  }

  String _generateInviteCode() {
    final random = const Uuid()
        .v4()
        .replaceAll('-', '')
        .substring(0, 8)
        .toUpperCase();
    return random;
  }

  void reset() {
    emit(const CreateCampaignState());
  }
}
