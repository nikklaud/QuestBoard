import 'package:equatable/equatable.dart';

class CampaignHero extends Equatable {
  final String id;
  final String campaignId;
  final String name;
  final String playerId;
  final DateTime? createdAt;

  const CampaignHero({
    required this.id,
    required this.campaignId,
    required this.name,
    required this.playerId,
    this.createdAt,
  });

  factory CampaignHero.fromMap(String id, Map<String, dynamic> data) {
    return CampaignHero(
      id: id,
      campaignId: data['campaignId'] ?? '',
      name: data['name'] ?? '',
      playerId: data['playerId'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'campaignId': campaignId,
      'name': name,
      'playerId': playerId,
      'createdAt': createdAt,
    };
  }

  CampaignHero copyWith({
    String? id,
    String? campaignId,
    String? name,
    String? playerId,
    DateTime? createdAt,
  }) {
    return CampaignHero(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      name: name ?? this.name,
      playerId: playerId ?? this.playerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, campaignId, name, playerId, createdAt];
}
