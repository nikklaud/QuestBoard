import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:quest_board/campaign_list/data/model/custom_month.dart';
import 'package:quest_board/campaign_list/data/model/day_of_week.dart';

class Campaign extends Equatable {
  final String id;
  final String campaignName;
  final String worldName;
  final String ownerId;
  final String inviteCode;
  final List<DayOfWeek> daysOfWeek;
  final List<CustomMonth> months;
  final List<String> playerIds;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Campaign({
    required this.id,
    required this.campaignName,
    required this.worldName,
    required this.ownerId,
    required this.inviteCode,
    required this.daysOfWeek,
    required this.months,
    this.playerIds = const [],
    required this.createdAt,
    this.updatedAt,
  });

  factory Campaign.fromMap(String id, Map<String, dynamic> data) {
    DateTime _parseDate(dynamic dateValue) {
      if (dateValue == null) {
        return DateTime.now();
      }

      if (dateValue is Timestamp) {
        return dateValue.toDate();
      }

      if (dateValue is String) {
        return DateTime.parse(dateValue);
      }

      return DateTime.now();
    }

    return Campaign(
      id: id,
      campaignName: data['campaignName'] ?? '',
      worldName: data['worldName'] ?? '',
      ownerId: data['ownerId'] ?? '',
      inviteCode: data['inviteCode'] ?? '',
      daysOfWeek:
          (data['daysOfWeek'] as List<dynamic>?)
              ?.map((e) => DayOfWeek.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      months:
          (data['months'] as List<dynamic>?)
              ?.map((e) => CustomMonth.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      playerIds: List<String>.from(data['playerIds'] ?? []),
      createdAt: _parseDate(data['createdAt']),
      // updatedAt intentionally remains null when absent; _parseDate would incorrectly
      // return DateTime.now() instead of preserving nullability
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'campaignName': campaignName,
      'worldName': worldName,
      'ownerId': ownerId,
      'inviteCode': inviteCode,
      'daysOfWeek': daysOfWeek.map((e) => e.toMap()).toList(),
      'months': months.map((e) => e.toMap()).toList(),
      'playerIds': playerIds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Campaign copyWith({
    String? id,
    String? campaignName,
    String? worldName,
    String? ownerId,
    String? inviteCode,
    List<DayOfWeek>? daysOfWeek,
    List<CustomMonth>? months,
    List<String>? playerIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Campaign(
      id: id ?? this.id,
      campaignName: campaignName ?? this.campaignName,
      worldName: worldName ?? this.worldName,
      ownerId: ownerId ?? this.ownerId,
      inviteCode: inviteCode ?? this.inviteCode,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      months: months ?? this.months,
      playerIds: playerIds ?? this.playerIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    campaignName,
    worldName,
    ownerId,
    inviteCode,
    daysOfWeek,
    months,
    playerIds,
    createdAt,
    updatedAt,
  ];
}
