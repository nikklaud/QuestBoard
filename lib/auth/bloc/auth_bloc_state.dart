part of 'auth_bloc.dart';

class AuthBlocState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthBlocInitial extends AuthBlocState {}

class AuthLoading extends AuthBlocState {}

class AuthFailure extends AuthBlocState {
  final String message;
  AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthAuthenticated extends AuthBlocState {
  final AppUser user;

  AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthBlocState {}
