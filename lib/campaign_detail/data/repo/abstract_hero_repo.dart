import 'package:quest_board/campaign_detail/data/model/hero.dart';

abstract class AbstractHeroRepo {
  Future<List<CampaignHero>> getHeroesByCampaign(String campaignId);
  Future<CampaignHero?> getHeroById(String heroId);
  Future<void> createHero(CampaignHero hero);
  Future<void> updateHero(CampaignHero hero);
  Future<void> deleteHero(String heroId);
}
