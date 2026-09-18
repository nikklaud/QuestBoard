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
  Future<String?> getCampaignIdByInviteCode(String inviteCode) async {
    try {
      final doc = await _firebaseFirestore
          .collection('campaignInvites')
          .doc(inviteCode)
          .get();

      if (!doc.exists) {
        return null;
      }
      return doc.data()?['campaignId'] as String?;
    } catch (e) {
      GetIt.I<Talker>().error('Error getting campaign id by invite code: $e');
      rethrow;
    }
  }

  @override
  Future<void> createCampaign(Campaign campaign) async {
    try {
      final batch = _firebaseFirestore.batch();
      batch.set(
        _firebaseFirestore.collection('campaigns').doc(campaign.id),
        campaign.toMap(),
      );
      batch.set(
        _firebaseFirestore
            .collection('campaignInvites')
            .doc(campaign.inviteCode),
        {'campaignId': campaign.id},
      );
      await batch.commit();
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
      final campaignRef = _firebaseFirestore
          .collection('campaigns')
          .doc(campaignId);
      final campaign = await campaignRef.get();
      if (!campaign.exists) return;

      final batch = _firebaseFirestore.batch();

      // Delete quests
      final questsSnapshot = await _firebaseFirestore
          .collection('quests')
          .where('campaignId', isEqualTo: campaignId)
          .get();
      for (final doc in questsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete heroes
      final heroesSnapshot = await _firebaseFirestore
          .collection('heroes')
          .where('campaignId', isEqualTo: campaignId)
          .get();
      for (final doc in heroesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete campaign
      batch.delete(campaignRef);
      final inviteCode = campaign.data()?['inviteCode'] as String?;
      if (inviteCode != null && inviteCode.isNotEmpty) {
        batch.delete(
          _firebaseFirestore.collection('campaignInvites').doc(inviteCode),
        );
      }

      await batch.commit();
      GetIt.I<Talker>().debug('Campaign and related data deleted: $campaignId');
    } catch (e) {
      GetIt.I<Talker>().error('Error deleting campaign: $e');
      rethrow;
    }
  }

  @override
  Future<Campaign> joinCampaign(String campaignId, String userId) async {
    try {
      await _firebaseFirestore.collection('campaigns').doc(campaignId).update({
        'playerIds': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final campaign = await getCampaignById(campaignId);
      if (campaign == null) {
        throw StateError('Campaign not found after joining');
      }
      GetIt.I<Talker>().debug('User $userId joined campaign $campaignId');
      return campaign;
    } catch (e) {
      GetIt.I<Talker>().error('Error joining campaign: $e');
      rethrow;
    }
  }
}
