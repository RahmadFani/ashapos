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
          'assets/ashapos/logo15.png',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        )),
      ),
    );
  }
}
