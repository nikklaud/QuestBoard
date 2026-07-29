import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:quest_board/campaign_detail/data/model/hero.dart';
import 'package:quest_board/campaign_detail/data/repo/abstract_hero_repo.dart';
import 'package:talker_flutter/talker_flutter.dart';

class HeroRepo extends AbstractHeroRepo {
  final FirebaseFirestore firebaseFirestore;

  HeroRepo({required this.firebaseFirestore});

  @override
  Future<List<CampaignHero>> getHeroesByCampaign(String campaignId) async {
    try {
      final snapshot = await firebaseFirestore
          .collection('heroes')
          .where('campaignId', isEqualTo: campaignId)
          .get();

      return snapshot.docs
          .map((doc) => CampaignHero.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      GetIt.I<Talker>().error('Error getting heroes by campaign: $e');
      rethrow;
    }
  }

  @override
  Future<CampaignHero?> getHeroById(String heroId) async {
    try {
      final doc = await firebaseFirestore
          .collection('heroes')
          .doc(heroId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return CampaignHero.fromMap(doc.id, doc.data()!);
    } catch (e) {
      GetIt.I<Talker>().error('Error getting hero by id: $e');
      rethrow;
    }
  }

  @override
  Future<void> createHero(CampaignHero hero) async {
    try {
      await firebaseFirestore
          .collection('heroes')
          .doc(hero.id)
          .set(hero.toMap());
      GetIt.I<Talker>().debug('Hero created: ${hero.name}');
    } catch (e) {
      GetIt.I<Talker>().error('Error creating hero: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateHero(CampaignHero hero) async {
    try {
      await firebaseFirestore
          .collection('heroes')
          .doc(hero.id)
          .update(hero.toMap());
    } catch (e) {
      GetIt.I<Talker>().error('Error updating hero: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteHero(String heroId) async {
    try {
      await firebaseFirestore.collection('heroes').doc(heroId).delete();
    } catch (e) {
      GetIt.I<Talker>().error('Error deleting hero: $e');
      rethrow;
    }
  }
}
