import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:quest_board/auth/data/model/app_user.dart';
import 'package:quest_board/auth/data/repo/abstract_auth_repo.dart';
import 'package:talker_flutter/talker_flutter.dart';

class AuthRepo implements AbstractAuthRepo {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseFirestore;

  AuthRepo({required this._firebaseAuth, required this._firebaseFirestore});

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    //login user on firebase auth
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    //find user doc in firestore
    final uid = credential.user!.uid;

    final doc = await _firebaseFirestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      GetIt.I<Talker>().error('User with email: $email not found');
      throw Exception('User with email: $email not found');
    }

    final user = AppUser.fromMap(doc.id, doc.data()!);
    // Backfill the non-sensitive display profile for accounts created before
    // Firestore rules separated private user data from public nicknames.
    await _firebaseFirestore.collection('publicProfiles').doc(uid).set({
      'nickname': user.nickname,
    });
    return user;
  }

  @override
  Future<AppUser> register({
    required String email,
    required String password,
    required String nickname,
  }) async {
    //register user in firebase auth
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    //create user doc in firestore
    final uid = credential.user!.uid;

    final user = AppUser(
      id: uid,
      email: email,
      nickname: nickname,
      myCampaignIds: [],
      joinedCampaignIds: [],
    );

    final batch = _firebaseFirestore.batch();
    batch.set(_firebaseFirestore.collection('users').doc(uid), user.toMap());
    batch.set(_firebaseFirestore.collection('publicProfiles').doc(uid), {
      'nickname': nickname,
    });
    await batch.commit();
    return user;
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final currentAppUser = _firebaseAuth.currentUser;
    if (currentAppUser == null) {
      return null;
    }
    try {
      final doc = await _firebaseFirestore
          .collection('users')
          .doc(currentAppUser.uid)
          .get();

      if (!doc.exists) {
        return null;
      }
      final user = AppUser.fromMap(doc.id, doc.data()!);
      await _firebaseFirestore.collection('publicProfiles').doc(user.id).set({
        'nickname': user.nickname,
      });
      return user;
    } on FirebaseException catch (e) {
      GetIt.I<Talker>().warning(
        'Firestore error in getCurrentUser (treating as unauthenticated): ${e.code}',
      );
      return null;
    } catch (e) {
      GetIt.I<Talker>().error('Unexpected error in getCurrentUser: $e');
      return null;
    }
  }

  @override
  Future<String?> getPublicNicknameById(String userId) async {
    try {
      final doc = await _firebaseFirestore
          .collection('publicProfiles')
          .doc(userId)
          .get();

      if (!doc.exists) {
        return null;
      }
      return doc.data()?['nickname'] as String?;
    } on FirebaseException catch (e) {
      GetIt.I<Talker>().warning(
        'Firestore error in getPublicNicknameById: ${e.code}',
      );
      return null;
    } catch (e) {
      GetIt.I<Talker>().error('Unexpected error in getPublicNicknameById: $e');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    //logout from account
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> deleteAccount({required String nickname}) async {
    final authUser = _firebaseAuth.currentUser;
    if (authUser == null) {
      throw StateError('No signed-in user found');
    }

    final userRef = _firebaseFirestore.collection('users').doc(authUser.uid);
    final userDoc = await userRef.get();
    final currentNickname = userDoc.data()?['nickname'] as String?;
    if (currentNickname == null || nickname.trim() != currentNickname) {
      throw ArgumentError('The nickname does not match');
    }

    // Delete Firestore profile data while the user still has an authenticated
    // Firestore session, then remove the Firebase Authentication identity.
    final batch = _firebaseFirestore.batch();
    batch.delete(userRef);
    batch.delete(
      _firebaseFirestore.collection('publicProfiles').doc(authUser.uid),
    );
    await batch.commit();

    try {
      await authUser.delete();
    } on FirebaseAuthException catch (error) {
      if (error.code == 'requires-recent-login') {
        throw StateError(
          'For security, sign out and sign in again before deleting the account.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> updateUserJoinedCampaigns(
    String userId,
    List<String> campaignIds,
  ) async {
    try {
      await _firebaseFirestore.collection('users').doc(userId).update({
        'joinedCampaignIds': campaignIds,
      });
      GetIt.I<Talker>().debug('Updated user $userId joined campaigns');
    } catch (e) {
      GetIt.I<Talker>().error('Error updating user joined campaigns: $e');
      rethrow;
    }
  }
}
