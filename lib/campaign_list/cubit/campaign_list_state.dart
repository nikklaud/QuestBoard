part of 'campaign_list_cubit.dart';

class CampaignListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CampaignListInitial extends CampaignListState {}

class CampaignListLoading extends CampaignListState {}

class CampaignListLoaded extends CampaignListState {
  final List<Campaign> ownedCampaigns;
  final List<Campaign> joinedCampaigns;

  CampaignListLoaded({
    required this.ownedCampaigns,
    required this.joinedCampaigns,
  });

  @override
  List<Object?> get props => [ownedCampaigns, joinedCampaigns];
}

class CampaignListError extends CampaignListState {
  final String message;

  CampaignListError(this.message);

  @override
  List<Object?> get props => [message];
}
