import 'package:bloc/bloc.dart';

import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<CheckAuthStatusEvent>((event, emit) async {
      emit(AuthLoading());
      await Future.delayed(Duration(seconds: 3));
      emit(AuthUnauthenticated());
    });

    on<LogingEvent>((event, emit) async {
      emit(AuthLoading());
      await Future.delayed(Duration(seconds: 1)); // Simulating a delay
      if (event.username == "Admin" && event.passoword == "password") {
        emit(AuthAuthenticated());
      } else {
        emit(AuthError("Invalid username or password"));
      }
    });

      on<LogoutEvent>((event, emit) async{
       emit(AuthUnauthenticated());
    });
  }
}
