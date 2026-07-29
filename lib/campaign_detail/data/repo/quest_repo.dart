import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:quest_board/campaign_detail/data/model/quest.dart';
import 'package:quest_board/campaign_detail/data/repo/abstract_quest_repo.dart';
import 'package:talker_flutter/talker_flutter.dart';

class QuestRepo implements AbstractQuestRepo {
  final FirebaseFirestore firebaseFirestore;

  QuestRepo({required this.firebaseFirestore});

  @override
  Future<List<Quest>> getQuestsByCampaign(String campaignId) async {
    try {
      final snapshot = await firebaseFirestore
          .collection('quests')
          .where('campaignId', isEqualTo: campaignId)
          .get();

      return snapshot.docs
          .map((doc) => Quest.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      GetIt.I<Talker>().error('Error getting quests by campaign: $e');
      rethrow;
    }
  }

  @override
  Future<Quest?> getQuestById(String questId) async {
    try {
      final doc = await firebaseFirestore
          .collection('quests')
          .doc(questId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return Quest.fromMap(doc.id, doc.data()!);
    } catch (e) {
      GetIt.I<Talker>().error('Error getting quest by id: $e');
      rethrow;
    }
  }

  @override
  Future<void> createQuest(Quest quest) async {
    try {
      await firebaseFirestore
          .collection('quests')
          .doc(quest.id)
          .set(quest.toMap());
      GetIt.I<Talker>().debug('Quest created: ${quest.title}');
    } catch (e) {
      GetIt.I<Talker>().error('Error creating quest: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateQuest(Quest quest) async {
    try {
      await firebaseFirestore
          .collection('quests')
          .doc(quest.id)
          .update(quest.toMap());
    } catch (e) {
      GetIt.I<Talker>().error('Error updating quest: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteQuest(String questId) async {
    try {
      await firebaseFirestore.collection('quests').doc(questId).delete();
    } catch (e) {
      GetIt.I<Talker>().error('Error deleting quest: $e');
      rethrow;
    }
  }

  @override
  Future<List<Quest>> getQuestsAffectedByMonthChange(
    String campaignId, {
    required int monthOrder,
    required int newDaysCount,
  }) async {
    try {
      final snapshot = await firebaseFirestore
          .collection('quests')
          .where('campaignId', isEqualTo: campaignId)
          .where('startMonthIndex', isEqualTo: monthOrder)
          .get();

      final affectedQuests = <Quest>[];
      for (final doc in snapshot.docs) {
        final quest = Quest.fromMap(doc.id, doc.data());
        if (quest.startDayNumber > newDaysCount ||
            quest.endDayNumber > newDaysCount) {
          affectedQuests.add(quest);
        }
      }

      return affectedQuests;
    } catch (e) {
      GetIt.I<Talker>().error('Error getting affected quests: $e');
      return [];
    }
  }
}
