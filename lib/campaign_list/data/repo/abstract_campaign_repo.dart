import 'package:quest_board/campaign_list/data/model/campaign.dart';

abstract class AbstractCampaignRepo {
  Future<List<Campaign>> getCampaignsByOwner(String userId);
  Future<List<Campaign>> getCampaignsByPlayer(String userId);
  Future<Campaign?> getCampaignById(String campaignId);
  Future<Campaign?> getCampaignByInviteCode(String inviteCode);
  Future<void> createCampaign(Campaign campaign);
  Future<void> updateCampaign(Campaign campaign);
  Future<void> deleteCampaign(String campaignId);
  Future<void> joinCampaign(String campaignId, String userId);
}
