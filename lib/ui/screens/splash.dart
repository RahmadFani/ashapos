import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => SplashPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Center(
            child: Image.asset(
          'assets/ashapos/bontanglogo_2.png',
          width: 100,
          height: 100,
          fit: BoxFit.contain,
        )),
      ),
    );
  }
}
