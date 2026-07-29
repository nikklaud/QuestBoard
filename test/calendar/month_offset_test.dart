import 'package:flutter_test/flutter_test.dart';
import 'package:quest_board/campaign_list/data/model/custom_month.dart';

void main() {
  group('_computeMonthOffset', () {
    test('first month returns 0', () {
      final months = [CustomMonth(name: 'M1', daysCount: 30, order: 0)];
      expect(_computeMonthOffset(months, 0, 7), equals(0));
    });

    test('offset accumulates from previous months', () {
      final months = [
        CustomMonth(name: 'M1', daysCount: 30, order: 0), // 30 % 7 = 2
        CustomMonth(name: 'M2', daysCount: 31, order: 1), // 31 % 7 = 3
      ];
      // Month 1 offset = 0
      expect(_computeMonthOffset(months, 0, 7), equals(0));
      // Month 2 offset = 30 % 7 = 2
      expect(_computeMonthOffset(months, 1, 7), equals(2));
    });

    test('handles empty daysOfWeekLength', () {
      final months = [CustomMonth(name: 'M1', daysCount: 30, order: 0)];
      expect(_computeMonthOffset(months, 0, 0), equals(0));
    });

    test('handles custom week length', () {
      final months = [
        CustomMonth(name: 'M1', daysCount: 10, order: 0), // 10 % 5 = 0
        CustomMonth(name: 'M2', daysCount: 10, order: 1), // 10 % 5 = 0, offset = 0
      ];
      expect(_computeMonthOffset(months, 0, 5), equals(0));
      expect(_computeMonthOffset(months, 1, 5), equals(0));
    });
  });
}

int _computeMonthOffset(List<CustomMonth> sortedMonths, int monthIndex, int daysOfWeekLength) {
  if (daysOfWeekLength == 0) return 0;
  int offset = 0;
  for (int i = 0; i < monthIndex; i++) {
    offset = (offset + sortedMonths[i].daysCount) % daysOfWeekLength;
  }
  return offset;
}
