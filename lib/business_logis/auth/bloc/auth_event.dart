part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}

class LogingEvent extends AuthEvent {
  final String username;
  final String passoword;

  LogingEvent({required this.username, required this.passoword});

}

class LogoutEvent extends AuthEvent{}