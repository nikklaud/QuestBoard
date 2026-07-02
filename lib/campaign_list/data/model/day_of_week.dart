import 'package:equatable/equatable.dart';

class DayOfWeek extends Equatable {
  final String name;
  final int order;

  const DayOfWeek({required this.name, required this.order});

  factory DayOfWeek.fromMap(Map<String, dynamic> data) {
    return DayOfWeek(name: data['name'] ?? '', order: data['order'] ?? 0);
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'order': order};
  }

  DayOfWeek copyWith({String? name, int? order}) {
    return DayOfWeek(name: name ?? this.name, order: order ?? this.order);
  }

  @override
  List<Object?> get props => [name, order];
}
