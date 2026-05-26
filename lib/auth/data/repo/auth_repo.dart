import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:quest_board/auth/data/model/app_user.dart';
import 'package:quest_board/auth/data/repo/abstract_auth_repo.dart';
import 'package:talker_flutter/talker_flutter.dart';

class AuthRepo implements AbstractAuthRepo {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

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

    return AppUser.fromMap(doc.id, doc.data()!);
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

    await _firebaseFirestore.collection('users').doc(uid).set(user.toMap());
    return user;
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    //request curent app user
    final currentAppUser = _firebaseAuth.currentUser;
    if (currentAppUser == null) {
      return null;
    }
    final doc = await _firebaseFirestore
        .collection('users')
        .doc(currentAppUser.uid)
        .get();

    if (!doc.exists) {
      return null;
    }
    return AppUser.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<void> logout() async {
    //logout from account
    await _firebaseAuth.signOut();
  }
}
