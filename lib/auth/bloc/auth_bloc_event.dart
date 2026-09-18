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
  // Never include credentials in equality/debug representations. This event is
  // still dispatched normally; Bloc does not deduplicate equal events.
  List<Object?> get props => [email];
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
  // See LoginRequest: credentials must not reach diagnostic output.
  List<Object?> get props => [email, nickname];
}

class CheckAuthStatusRequest extends AuthBlocEvent {
  @override
  List<Object?> get props => [];
}

class LogoutRequest extends AuthBlocEvent {
  @override
  List<Object?> get props => [];
}

class DeleteAccountRequest extends AuthBlocEvent {
  DeleteAccountRequest({required this.nickname});

  final String nickname;

  @override
  List<Object?> get props => [nickname];
}
