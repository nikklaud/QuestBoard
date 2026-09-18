import 'package:quest_board/auth/data/model/app_user.dart';

abstract class AbstractAuthRepo {
  Future<AppUser> register({
    required String email,
    required String password,
    required String nickname,
  });
  Future<AppUser> login({required String email, required String password});
  Future<AppUser?> getCurrentUser();
  Future<String?> getPublicNicknameById(String userId);
  Future<void> logout();
  Future<void> deleteAccount({required String nickname});
  Future<void> updateUserJoinedCampaigns(
    String userId,
    List<String> campaignIds,
  );
}
