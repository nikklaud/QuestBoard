part of 'auth_bloc.dart';

class AuthBlocEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequest extends AuthBlocEvent {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});
  //equatable
  @override
  List<Object?> get props => [email, password];
}

class RegisterRequest extends AuthBlocEvent {
  final String email;
  final String password;
  final String nickname;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.nickname,
  });

  @override
  List<Object?> get props => [email, password, nickname];
}

class CheckAuthStatusRequest extends AuthBlocEvent {
  @override
  List<Object?> get props => [];
}

class LogoutRequest extends AuthBlocEvent {
  @override
  List<Object?> get props => [];
}
