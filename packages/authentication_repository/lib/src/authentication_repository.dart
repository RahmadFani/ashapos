import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:authentication_repository/helpers/api.dart';
import 'package:authentication_repository/src/model/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart';
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
    await Future.delayed(Duration(seconds: 4));
    initUser();
    yield* _controller.stream;
  }

  initUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String userData = pref.getString('user_model') ?? null;

    if (userData != null) {
      try {
        final json = jsonDecode(userData);
        final user = UserModel.fromJson(json);
        try {
          final getuserinfo = await http.post(
              Uri.parse(Api.url + 'get-user-info-by-email.php'),
              body: {'email': user.emailAddress});
          log(getuserinfo.body);
          SharedPreferences pref = await SharedPreferences.getInstance();
          pref.setString('user_model', getuserinfo.body);
          final json = jsonDecode(getuserinfo.body);
          final userupdated = UserModel.fromJson(json);
          setImage(userupdated);
          _controller
              .add(AuthenticationResponse.authenticated(userdata: userupdated));
        } catch (e) {
          _controller.add(AuthenticationResponse.authenticated(userdata: user));
        }
        return;
      } catch (e) {
        _controller.add(AuthenticationResponse.unauthenticated());
      }
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
      log('test');
      final result = await http.post(Uri.parse(Api.url + 'login.php'),
          body: {'email': email, 'password': password});
      final int responseCode = int.parse(result.body);
      // res == 0 => success
      log(responseCode.toString());
      if (responseCode == 0) {
        final getuserinfo = await http.post(
            Uri.parse(Api.url + 'get-user-info-by-email.php'),
            body: {'email': email});
        log(getuserinfo.body);
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString('user_model', getuserinfo.body);
        final json = jsonDecode(getuserinfo.body);
        final user = UserModel.fromJson(json);
        setImage(user);
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

  setImage(UserModel user) async {
    log('TEST SAVE IMAGE');
    final prefs = await SharedPreferences.getInstance();
    try {
      var url = user.logo; // <-- 1
      var response = await http.get(Uri.parse(url)); // <--2
      log(response.statusCode.toString());
      if (response.statusCode != 200) {
        return throw Error();
      }
      imageCache.clear();
      var documentDirectory = await getApplicationDocumentsDirectory();

      var firstPath = documentDirectory.path + "/images";
      var filePathAndName = documentDirectory.path +
          '/images/logo_outlet_etam_bersinar_bontang.png';
      //comment out the next three lines to prevent the image from being saved
      //to the device to show that it's coming from the internet
      await Directory(firstPath).create(recursive: true); // <-- 1

      File file2 = new File(filePathAndName); // <-- 2

      var image = decodeImage(response.bodyBytes);
      var thumbnail = copyResize(image, height: 150, width: 150);

      file2.writeAsBytes(encodePng(thumbnail));
      log(file2.path);

      prefs.setString('logo_outlet', file2.path);
    } on FileSystemException catch (error) {
      log('ERROR IMAGE SAVE SISTEM');
      log(error.message);
      log(error.path);
      prefs.remove('logo_outlet');
    } catch (e) {
      log('ERROR IMAGE SAVE');
      log(e.toString());
      prefs.remove('logo_outlet');
    }
  }
}
