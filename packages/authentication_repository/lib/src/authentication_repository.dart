import 'dart:async';
import 'dart:convert';

import 'package:authentication_repository/helpers/api.dart';
import 'package:authentication_repository/src/model/user_model.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum AuthenticationStatus { unknown, unauthenticated, authenticated }

class AuthenticationResponse {
  final AuthenticationStatus status;
  final String responseError;
  final UserModel user;

  const AuthenticationResponse(
      {this.status, this.responseError = '', this.user});

  String get error => responseError == null
      ? ''
      : responseError == 'wrong_email'
          ? 'Email belum terdaftar.'
          : responseError == 'wrong_password'
              ? 'Password yg anda masukan salah.'
              : 'Terjadi kesalahan.';

  const AuthenticationResponse._(
      {this.status, this.responseError = '', this.user});
  const AuthenticationResponse.unauthenticated({String error = ''})
      : this._(
            status: AuthenticationStatus.unauthenticated,
            responseError: error,
            user: null);
  const AuthenticationResponse.authenticated({@required UserModel userdata})
      : this._(status: AuthenticationStatus.authenticated, user: userdata);
}

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationResponse>();

  Stream<AuthenticationResponse> get onAuthenticationChanged async* {
    await Future.delayed(Duration(seconds: 2));
    initUser();
    yield* _controller.stream;
  }

  initUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String userData = pref.getString('user_model') ?? null;
    if (userData != null) {
      final json = jsonDecode(userData);
      final user = UserModel.fromJson(json);
      _controller.add(AuthenticationResponse.authenticated(userdata: user));
      return;
    }
    _controller.add(AuthenticationResponse.unauthenticated());
  }

  Future<void> logOut() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove('user_model');
    _controller.add(AuthenticationResponse.unauthenticated());
  }

  Future<void> logIn({
    @required String email,
    @required String password,
  }) async {
    try {
      final result = await http.post(Uri.parse(Api.url + 'login.php'),
          body: {'email': email, 'password': password});
      final int responseCode = int.parse(result.body);
      // res == 0 => success
      print(responseCode);
      if (responseCode == 0) {
        final getuserinfo = await http.post(
            Uri.parse(Api.url + 'get-user-info-by-email.php'),
            body: {'email': email});
        print(getuserinfo.body);
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString('user_model', getuserinfo.body);
        final json = jsonDecode(getuserinfo.body);
        final user = UserModel.fromJson(json);
        _controller.add(AuthenticationResponse.authenticated(userdata: user));
      }

      if (responseCode == -1) {
        _controller.add(
            AuthenticationResponse.unauthenticated(error: 'wrong_password'));
      }

      if (responseCode == -2) {
        _controller
            .add(AuthenticationResponse.unauthenticated(error: 'wrong_email'));
      }
    } catch (e) {
      print(e.toString());
      _controller.add(AuthenticationResponse.unauthenticated(error: 'unknown'));
    }
  }
}
