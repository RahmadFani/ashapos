import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {

  final AuthenticationRepository _authenticationRepository;
  StreamSubscription _subscription;

  AuthenticationCubit(
    {
      @required AuthenticationRepository authenticationRepository
    }
  ) :
    assert(authenticationRepository != null),
    _authenticationRepository = authenticationRepository,
   super(const AuthenticationState.unknown()) {
     _subscription = _authenticationRepository.onAuthenticationChanged.listen((event) { 
       authenticationChanged(event);
     });
   }

  void authenticationChanged(AuthenticationResponse response) async {
    switch (response.status) {
      case AuthenticationStatus.unauthenticated:
        return emit( AuthenticationState.unauthenticated(
          error: response.error));
      case AuthenticationStatus.authenticated:
        return emit(AuthenticationState.authenticated(
          userData: response.user
        ));
      default:
        return emit(const AuthenticationState.unknown());
    }
  }


  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
