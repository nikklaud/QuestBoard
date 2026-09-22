import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_board/campaign_detail/data/model/hero.dart';
import 'package:quest_board/campaign_detail/data/model/quest.dart';
import 'package:quest_board/campaign_list/data/model/campaign.dart';

void main() {
  group('Model date parsing tests', () {
    test('Campaign.fromMap handles Timestamp, String, DateTime, and null', () {
      final now = DateTime(2026, 1, 15, 12, 0);

      // Null dates
      final c1 = Campaign.fromMap('c1', {
        'campaignName': 'Campaign 1',
        'worldName': 'World 1',
        'ownerId': 'u1',
        'inviteCode': 'INV123',
      });
      expect(c1.createdAt, isA<DateTime>());
      expect(c1.updatedAt, isNull);

      // Timestamp dates
      final c2 = Campaign.fromMap('c2', {
        'campaignName': 'Campaign 2',
        'worldName': 'World 2',
        'ownerId': 'u1',
        'inviteCode': 'INV123',
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });
      expect(c2.createdAt, equals(now));
      expect(c2.updatedAt, equals(now));

      // ISO-8601 String dates
      final c3 = Campaign.fromMap('c3', {
        'campaignName': 'Campaign 3',
        'worldName': 'World 3',
        'ownerId': 'u1',
        'inviteCode': 'INV123',
        'createdAt': '2026-01-15T12:00:00.000',
        'updatedAt': '2026-01-15T12:00:00.000',
      });
      expect(c3.createdAt, equals(now));
      expect(c3.updatedAt, equals(now));
    });

    test('CampaignHero.fromMap handles null, Timestamp, and String dates', () {
      final now = DateTime(2026, 2, 20, 10, 30);

      final h1 = CampaignHero.fromMap('h1', {
        'campaignId': 'c1',
        'name': 'Hero 1',
        'playerId': 'p1',
      });
      expect(h1.createdAt, isNull);

      final h2 = CampaignHero.fromMap('h2', {
        'campaignId': 'c1',
        'name': 'Hero 2',
        'playerId': 'p1',
        'createdAt': Timestamp.fromDate(now),
      });
      expect(h2.createdAt, equals(now));

      final h3 = CampaignHero.fromMap('h3', {
        'campaignId': 'c1',
        'name': 'Hero 3',
        'playerId': 'p1',
        'createdAt': '2026-02-20T10:30:00.000',
      });
      expect(h3.createdAt, equals(now));
    });

    test('Quest.fromMap handles null, Timestamp, and String dates', () {
      final now = DateTime(2026, 3, 10, 8, 0);

      final q1 = Quest.fromMap('q1', {
        'campaignId': 'c1',
        'title': 'Quest 1',
        'description': 'Desc',
      });
      expect(q1.createdAt, isNull);

      final q2 = Quest.fromMap('q2', {
        'campaignId': 'c1',
        'title': 'Quest 2',
        'description': 'Desc',
        'createdAt': Timestamp.fromDate(now),
      });
      expect(q2.createdAt, equals(now));

      final q3 = Quest.fromMap('q3', {
        'campaignId': 'c1',
        'title': 'Quest 3',
        'description': 'Desc',
        'createdAt': '2026-03-10T08:00:00.000',
      });
      expect(q3.createdAt, equals(now));
    });
  });
}
