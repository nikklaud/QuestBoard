part of 'join_campaign_cubit.dart';

class JoinCampaignState extends Equatable {
  const JoinCampaignState({
    this.inviteCode = '',
    this.status = JoinStatus.initial,
    this.errorMessage,
    this.campaignName,
  });

  final String inviteCode;
  final JoinStatus status;
  final String? errorMessage;
  final String? campaignName;

  JoinCampaignState copyWith({
    String? inviteCode,
    JoinStatus? status,
    String? errorMessage,
    String? campaignName,
  }) {
    return JoinCampaignState(
      inviteCode: inviteCode ?? this.inviteCode,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      campaignName: campaignName ?? this.campaignName,
    );
  }

  @override
  List<Object?> get props => [inviteCode, status, errorMessage, campaignName];
}

enum JoinStatus { initial, loading, success, error }
