import 'package:quest_board/auth/data/model/app_user.dart';
import 'package:quest_board/auth/data/repo/abstract_auth_repo.dart';

class AuthRepo implements AbstractAuthRepo {
  @override
  Future<AppUser> getUserById() {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

  @override
  Future<AppUser> login() {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<AppUser> register() {
    // TODO: implement register
    throw UnimplementedError();
  }
}
