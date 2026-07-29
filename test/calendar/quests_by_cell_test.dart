import 'package:flutter_test/flutter_test.dart';
import 'package:quest_board/campaign_detail/data/model/quest.dart';
import 'package:quest_board/campaign_list/data/model/custom_month.dart';

void main() {
  group('questsByCell computation', () {
    test('single-day quest appears only on its day', () {
      final months = [
        CustomMonth(name: 'M1', daysCount: 30, order: 0),
      ];
      final quests = [
        Quest(
          id: 'q1',
          campaignId: 'c1',
          title: 'Single',
          description: '',
          color: '#FF0000',
          startMonthIndex: 0,
          startDayNumber: 5,
          endMonthIndex: 0,
          endDayNumber: 5,
          heroIds: const [],
        ),
      ];

      final result = _computeQuestsByCell(quests, months);
      expect(result['0-5'], hasLength(1));
      expect(result['0-4'], isNull);
      expect(result['0-6'], isNull);
      expect(result['1-1'], isNull);
    });

    test('multi-day quest in same month', () {
      final months = [
        CustomMonth(name: 'M1', daysCount: 31, order: 0),
        CustomMonth(name: 'M2', daysCount: 30, order: 1),
      ];
      final quests = [
        Quest(
          id: 'q2',
          campaignId: 'c1',
          title: 'Multi',
          description: '',
          color: '#00FF00',
          startMonthIndex: 1,
          startDayNumber: 10,
          endMonthIndex: 1,
          endDayNumber: 15,
          heroIds: const [],
        ),
      ];

      final result = _computeQuestsByCell(quests, months);
      expect(result['1-10'], hasLength(1));
      expect(result['1-15'], hasLength(1));
      expect(result['1-9'], isNull);
      expect(result['1-16'], isNull);
    });

    test('cross-month quest spans all intermediate days', () {
      final months = [
        CustomMonth(name: 'M1', daysCount: 30, order: 0),
        CustomMonth(name: 'M2', daysCount: 31, order: 1),
        CustomMonth(name: 'M3', daysCount: 30, order: 2),
      ];
      final quests = [
        Quest(
          id: 'cross',
          campaignId: 'c1',
          title: 'Cross',
          description: '',
          color: '#0000FF',
          startMonthIndex: 0,
          startDayNumber: 28,
          endMonthIndex: 2,
          endDayNumber: 3,
          heroIds: const [],
        ),
      ];

      final result = _computeQuestsByCell(quests, months);
      expect(result['0-28'], hasLength(1));
      expect(result['0-29'], hasLength(1));
      expect(result['0-30'], hasLength(1));
      expect(result['1-1'], hasLength(1));
      expect(result['1-30'], hasLength(1));
      expect(result['1-31'], hasLength(1));
      expect(result['2-1'], hasLength(1));
      expect(result['2-3'], hasLength(1));
      expect(result['2-4'], isNull);
    });

    test('multiple quests on same day', () {
      final months = [
        CustomMonth(name: 'M1', daysCount: 30, order: 0),
      ];
      final quests = [
        Quest(
          id: 'q1',
          campaignId: 'c1',
          title: 'Q1',
          description: '',
          color: '#FF0000',
          startMonthIndex: 0,
          startDayNumber: 1,
          endMonthIndex: 0,
          endDayNumber: 5,
          heroIds: const [],
        ),
        Quest(
          id: 'q2',
          campaignId: 'c1',
          title: 'Q2',
          description: '',
          color: '#00FF00',
          startMonthIndex: 0,
          startDayNumber: 3,
          endMonthIndex: 0,
          endDayNumber: 3,
          heroIds: const [],
        ),
      ];

      final result = _computeQuestsByCell(quests, months);
      expect(result['0-3'], hasLength(2));
      expect(result['0-1'], hasLength(1));
      expect(result['0-5'], hasLength(1));
    });

    test('many quests on same day', () {
      final months = [
        CustomMonth(name: 'M1', daysCount: 30, order: 0),
      ];
      final quests = List.generate(10, (i) => Quest(
        id: 'q$i',
        campaignId: 'c1',
        title: 'Q$i',
        description: '',
        color: '#FF0000',
        startMonthIndex: 0,
        startDayNumber: 1,
        endMonthIndex: 0,
        endDayNumber: 1,
        heroIds: const [],
      ));

      final result = _computeQuestsByCell(quests, months);
      final cellQuests = result['0-1'];
      expect(cellQuests, hasLength(10));
    });
  });
}

Map<String, List<Quest>> _computeQuestsByCell(List<Quest> quests, List<CustomMonth> months) {
  final Map<String, List<Quest>> questsByCell = {};
  for (final quest in quests) {
    for (var m = quest.startMonthIndex; m <= quest.endMonthIndex; m++) {
      final monthDays = m < months.length ? months[m].daysCount : 30;
      final dayStart = m == quest.startMonthIndex ? quest.startDayNumber : 1;
      final dayEnd = m == quest.endMonthIndex ? quest.endDayNumber : monthDays;
      for (var d = dayStart; d <= dayEnd; d++) {
        final key = '$m-$d';
        questsByCell.putIfAbsent(key, () => []).add(quest);
      }
    }
  }
  return questsByCell;
}