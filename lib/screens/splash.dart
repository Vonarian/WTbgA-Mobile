import 'package:flutter/material.dart';

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 3000), () {
      Navigator.pushReplacementNamed(context, '/loading');
    });
    return Scaffold(
      appBar: AppBar(
        title: Text('App made by VonarianTheGreat'),
      ),
      body: Image.asset('assets/splash.gif'),
    );
  }
}
