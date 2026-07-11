import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:quest_board/auth/data/model/app_user.dart';
import 'package:quest_board/auth/data/repo/abstract_auth_repo.dart';
import 'package:talker_flutter/talker_flutter.dart';

part 'auth_bloc_event.dart';
part 'auth_bloc_state.dart';

class AuthBloc extends Bloc<AuthBlocEvent, AuthBlocState> {
  AuthBloc() : super(AuthBlocInitial()) {
    // Reactive auth state listener
    FirebaseAuth.instance.authStateChanges().listen((_) {
      add(CheckAuthStatusRequest());
    });

    //login
    on<LoginRequest>((event, emit) async {
      emit(AuthLoading());
      try {
        GetIt.I<Talker>().debug('Login request block event');
        final user = await GetIt.I<AbstractAuthRepo>().login(
          email: event.email,
          password: event.password,
        );
        emit(AuthAuthenticated(user));
      } catch (e) {
        GetIt.I<Talker>().error(e.toString());
        emit(AuthFailure(e.toString()));
      }
    });
    //  register
    on<RegisterRequest>((event, emit) async {
      emit(AuthLoading());
      try {
        GetIt.I<Talker>().debug('Register request block event');
        final user = await GetIt.I<AbstractAuthRepo>().register(
          email: event.email,
          password: event.password,
          nickname: event.nickname,
        );
        emit(AuthAuthenticated(user));
        GetIt.I<Talker>().debug('User: ${user.nickname} succesfull registered');
      } catch (e) {
        emit(AuthFailure(e.toString()));
        GetIt.I<Talker>().error(e.toString());
      }
    });

    //Check auth status
    on<CheckAuthStatusRequest>((event, emit) async {
      try {
        final user = await GetIt.I<AbstractAuthRepo>().getCurrentUser();

        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        GetIt.I<Talker>().error('CheckAuthStatusRequest failed: $e');
        emit(AuthFailure(e.toString()));
      }
    });

    //Logout
    on<LogoutRequest>((event, emit) async {
      try {
        await GetIt.I<AbstractAuthRepo>().logout();
        emit(AuthUnauthenticated());
      } catch (e) {
        emit(AuthFailure(e.toString()));
        GetIt.I<Talker>().error(e.toString());
      }
    });

    // Initial auth check
    Future.microtask(() => add(CheckAuthStatusRequest()));
  }
}
