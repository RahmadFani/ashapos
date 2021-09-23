part of 'authentication_cubit.dart';

class AuthenticationState  {
  const AuthenticationState._({
    this.status = AuthenticationStatus.unknown,
    this.errorMessage = '',
    this.user
  }); 

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.unauthenticated({String error = ''}) : this._(status: AuthenticationStatus.unauthenticated, errorMessage: error, user: null);

  const AuthenticationState.authenticated({@required UserModel userData}) : this._(
    status: AuthenticationStatus.authenticated,
    user: userData
  );

  final UserModel user;
  final AuthenticationStatus status;
  final String errorMessage;

  bool get isUnknown => status == AuthenticationStatus.unknown;
  bool get isUnauthenticated => status == AuthenticationStatus.unauthenticated;
  bool get isAuthenticated => status == AuthenticationStatus.authenticated;


}

