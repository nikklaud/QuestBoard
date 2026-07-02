import 'package:equatable/equatable.dart';

class CustomMonth extends Equatable {
  final String name;
  final int daysCount;
  final int order;

  const CustomMonth({
    required this.name,
    required this.daysCount,
    required this.order,
  });

  factory CustomMonth.fromMap(Map<String, dynamic> data) {
    return CustomMonth(
      name: data['name'] ?? '',
      daysCount: data['daysCount'] ?? 1,
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'daysCount': daysCount, 'order': order};
  }

  CustomMonth copyWith({String? name, int? daysCount, int? order}) {
    return CustomMonth(
      name: name ?? this.name,
      daysCount: daysCount ?? this.daysCount,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [name, daysCount, order];
}
