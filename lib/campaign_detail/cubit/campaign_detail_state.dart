part of 'campaign_detail_cubit.dart';

enum CampaignDetailStatus { initial, loading, loaded, error }

class CampaignDetailState extends Equatable {
  const CampaignDetailState({
    this.status = CampaignDetailStatus.initial,
    this.campaign,
    this.quests = const [],
    this.heroes = const [],
    this.isOwner = false,
    this.errorMessage,
    this.questsByCell = const {},
  });

  final CampaignDetailStatus status;
  final Campaign? campaign;
  final List<Quest> quests;
  final List<CampaignHero> heroes;
  final bool isOwner;
  final String? errorMessage;
  final Map<String, List<Quest>> questsByCell;

  CampaignDetailState copyWith({
    CampaignDetailStatus? status,
    Campaign? campaign,
    List<Quest>? quests,
    List<CampaignHero>? heroes,
    bool? isOwner,
    String? errorMessage,
    Map<String, List<Quest>>? questsByCell,
  }) {
    return CampaignDetailState(
      status: status ?? this.status,
      campaign: campaign ?? this.campaign,
      quests: quests ?? this.quests,
      heroes: heroes ?? this.heroes,
      isOwner: isOwner ?? this.isOwner,
      errorMessage: errorMessage ?? this.errorMessage,
      questsByCell: questsByCell ?? this.questsByCell,
    );
  }

  @override
  List<Object?> get props => [
    status,
    campaign,
    quests,
    heroes,
    isOwner,
    errorMessage,
    questsByCell,
  ];
}
