import 'package:quest_board/campaign_detail/data/model/quest.dart';

abstract class AbstractQuestRepo {
  Future<List<Quest>> getQuestsByCampaign(String campaignId);
  Future<Quest?> getQuestById(String questId);
  Future<List<Quest>> getQuestsAffectedByMonthChange(
    String campaignId, {
    required int monthOrder,
    required int newDaysCount,
  });
  Future<void> createQuest(Quest quest);
  Future<void> updateQuest(Quest quest);
  Future<void> deleteQuest(String questId);
}
