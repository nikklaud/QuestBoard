import 'package:quest_board/auth/data/model/app_user.dart';

abstract class AbstractAuthRepo {
  Future<AppUser> register();
  Future<AppUser> login();
  Future<AppUser> getUserById();
}
