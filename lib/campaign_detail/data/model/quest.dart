import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Quest extends Equatable {
  final String id;
  final String campaignId;
  final String title;
  final String description;
  final String color;
  final int startMonthIndex;
  final int startDayNumber;
  final int endMonthIndex;
  final int endDayNumber;
  final List<String> heroIds;
  final DateTime? createdAt;

  const Quest({
    required this.id,
    required this.campaignId,
    required this.title,
    required this.description,
    required this.color,
    required this.startMonthIndex,
    required this.startDayNumber,
    required this.endMonthIndex,
    required this.endDayNumber,
    required this.heroIds,
    this.createdAt,
  });

  Color get displayColor {
    try {
      final hexColor = color.replaceFirst('#', '0xFF');
      return Color(int.parse(hexColor)).withValues(alpha: 0.8);
    } catch (_) {
      return Colors.grey.withValues(alpha: 0.8);
    }
  }

  factory Quest.fromMap(String id, Map<String, dynamic> data) {
    return Quest(
      id: id,
      campaignId: data['campaignId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      color: data['color'] ?? '#FF6B6B',
      startMonthIndex: data['startMonthIndex'] ?? 0,
      startDayNumber: data['startDayNumber'] ?? 1,
      endMonthIndex: data['endMonthIndex'] ?? 0,
      endDayNumber: data['endDayNumber'] ?? 1,
      heroIds: List<String>.from(data['heroIds'] ?? []),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'campaignId': campaignId,
      'title': title,
      'description': description,
      'color': color,
      'startMonthIndex': startMonthIndex,
      'startDayNumber': startDayNumber,
      'endMonthIndex': endMonthIndex,
      'endDayNumber': endDayNumber,
      'heroIds': heroIds,
      'createdAt': createdAt,
    };
  }

  Quest copyWith({
    String? id,
    String? campaignId,
    String? title,
    String? description,
    String? color,
    int? startMonthIndex,
    int? startDayNumber,
    int? endMonthIndex,
    int? endDayNumber,
    List<String>? heroIds,
    DateTime? createdAt,
  }) {
    return Quest(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      startMonthIndex: startMonthIndex ?? this.startMonthIndex,
      startDayNumber: startDayNumber ?? this.startDayNumber,
      endMonthIndex: endMonthIndex ?? this.endMonthIndex,
      endDayNumber: endDayNumber ?? this.endDayNumber,
      heroIds: heroIds ?? this.heroIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    campaignId,
    title,
    description,
    color,
    startMonthIndex,
    startDayNumber,
    endMonthIndex,
    endDayNumber,
    heroIds,
    createdAt,
  ];
}
