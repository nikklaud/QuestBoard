part of 'create_campaign_cubit.dart';

class CreateCampaignState extends Equatable {
  const CreateCampaignState({
    this.campaignName = '',
    this.worldName = '',
    this.months = const [],
    this.daysOfWeek = const [],
    this.status = CreateStatus.initial,
    this.errorMessage,
  });

  final String campaignName;
  final String worldName;
  final List<CustomMonth> months;
  final List<DayOfWeek> daysOfWeek;
  final CreateStatus status;
  final String? errorMessage;

  CreateCampaignState copyWith({
    String? campaignName,
    String? worldName,
    List<CustomMonth>? months,
    List<DayOfWeek>? daysOfWeek,
    CreateStatus? status,
    String? errorMessage,
  }) {
    return CreateCampaignState(
      campaignName: campaignName ?? this.campaignName,
      worldName: worldName ?? this.worldName,
      months: months ?? this.months,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        campaignName,
        worldName,
        months,
        daysOfWeek,
        status,
        errorMessage,
      ];
}

enum CreateStatus { initial, loading, success, error }