import 'package:ashapos/blocs/authentication/authentication_cubit.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => LoginPage());
  }

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isloading = false;
  String email = '';
  String password = '';

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
              height: 20,
              top: 40,
              left: 20,
              width: 20,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.green),
              )),
          Positioned(
              height: 20,
              top: 80,
              right: 30,
              width: 20,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), color: Colors.red),
              )),
          Positioned(
              height: 20,
              top: 150,
              left: 120,
              width: 20,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.yellow),
              )),
          Positioned(
              height: 20,
              bottom: 40,
              right: 30,
              width: 20,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.purple),
              )),
          Positioned(
              height: 20,
              bottom: 90,
              left: 90,
              width: 20,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blueGrey),
              )),
          Scaffold(
            backgroundColor: Colors.transparent,
            key: _scaffoldKey,
            body: BlocListener<AuthenticationCubit, AuthenticationState>(
              listener: (_, state) {
                if (state.isUnauthenticated) {
                  ScaffoldMessenger.of(_scaffoldKey.currentContext)
                      .showSnackBar(SnackBar(
                    content: Text(state.errorMessage),
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              },
              child: SizedBox.expand(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Masuk',
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            TextField(
                              onChanged: (text) {
                                setState(() {
                                  email = text;
                                });
                              },
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'Masukan Email..'),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              onChanged: (text) {
                                setState(() {
                                  password = text;
                                });
                              },
                              textInputAction: TextInputAction.done,
                              onSubmitted: (text) => logIn(),
                              obscureText: true,
                              decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: 'Masukan Password..'),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: !isloading
                                        ? MaterialStateProperty.all(
                                            Theme.of(context).primaryColor)
                                        : MaterialStateProperty.all(
                                            Colors.grey)),
                                onPressed: logIn,
                                child: Text('MASUK'),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void logIn() async {
    if (!email.contains('@'))
      ScaffoldMessenger.of(_scaffoldKey.currentContext)
          .showSnackBar(SnackBar(content: Text('Format email tidak benar..')));
    if (isloading) {
      return;
    }
    setState(() {
      isloading = true;
    });
    await RepositoryProvider.of<AuthenticationRepository>(context)
        .logIn(email: email, password: password);
    setState(() {
      isloading = false;
    });
  }
}
