import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:quest_board/campaign_list/data/model/campaign.dart';
import 'package:quest_board/campaign_list/data/repo/abstract_campaign_repo.dart';
import 'package:talker_flutter/talker_flutter.dart';

class CampaignRepo implements AbstractCampaignRepo {
  final FirebaseFirestore _firebaseFirestore;

  CampaignRepo({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;

  @override
  Future<List<Campaign>> getCampaignsByOwner(String userId) async {
    try {
      final snapshot = await _firebaseFirestore
          .collection('campaigns')
          .where('ownerId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => Campaign.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      GetIt.I<Talker>().error('Error getting campaigns by owner: $e');
      rethrow;
    }
  }

  @override
  Future<List<Campaign>> getCampaignsByPlayer(String userId) async {
    try {
      final snapshot = await _firebaseFirestore
          .collection('campaigns')
          .where('playerIds', arrayContains: userId)
          .get();

      return snapshot.docs
          .map((doc) => Campaign.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      GetIt.I<Talker>().error('Error getting campaigns by player: $e');
      rethrow;
    }
  }

  @override
  Future<Campaign?> getCampaignById(String campaignId) async {
    try {
      final doc = await _firebaseFirestore
          .collection('campaigns')
          .doc(campaignId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return Campaign.fromMap(doc.id, doc.data()!);
    } catch (e) {
      GetIt.I<Talker>().error('Error getting campaign by id: $e');
      rethrow;
    }
  }

  @override
  Future<Campaign?> getCampaignByInviteCode(String inviteCode) async {
    try {
      final snapshot = await _firebaseFirestore
          .collection('campaigns')
          .where('inviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }
      return Campaign.fromMap(snapshot.docs.first.id, snapshot.docs.first.data());
    } catch (e) {
      GetIt.I<Talker>().error('Error getting campaign by invite code: $e');
      rethrow;
    }
  }

  @override
  Future<void> createCampaign(Campaign campaign) async {
    try {
      await _firebaseFirestore
          .collection('campaigns')
          .doc(campaign.id)
          .set(campaign.toMap());
    } catch (e) {
      GetIt.I<Talker>().error('Error creating campaign: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateCampaign(Campaign campaign) async {
    try {
      await _firebaseFirestore
          .collection('campaigns')
          .doc(campaign.id)
          .update(campaign.toMap());
    } catch (e) {
      GetIt.I<Talker>().error('Error updating campaign: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCampaign(String campaignId) async {
    try {
      await _firebaseFirestore.collection('campaigns').doc(campaignId).delete();
    } catch (e) {
      GetIt.I<Talker>().error('Error deleting campaign: $e');
      rethrow;
    }
  }

  @override
  Future<void> joinCampaign(String campaignId, String userId) async {
    try {
      final campaign = await getCampaignById(campaignId);
      if (campaign != null) {
        final updatedPlayerIds = [...campaign.playerIds, userId];
        final updatedCampaign = Campaign(
          id: campaign.id,
          campaignName: campaign.campaignName,
          worldName: campaign.worldName,
          ownerId: campaign.ownerId,
          inviteCode: campaign.inviteCode,
          daysOfWeek: campaign.daysOfWeek,
          months: campaign.months,
          playerIds: updatedPlayerIds,
          createdAt: campaign.createdAt,
          updatedAt: DateTime.now(),
        );
        await updateCampaign(updatedCampaign);
        GetIt.I<Talker>().debug('User $userId joined campaign $campaignId');
      }
    } catch (e) {
      GetIt.I<Talker>().error('Error joining campaign: $e');
      rethrow;
    }
  }
}