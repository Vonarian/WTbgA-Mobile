import 'package:blinking_text/blinking_text.dart';
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
        centerTitle: true,
        title: Text('App made by VonarianTheGreat'),
      ),
      body: Stack(
        children: [
          Center(
              child: BlinkText(
            'Loading',
            duration: Duration(milliseconds: 1400),
            style: TextStyle(color: Colors.red),
          )),
          Center(
              child: SizedBox(
            height: 200,
            width: 200,
            child: CircularProgressIndicator(
              backgroundColor: Colors.red,
            ),
          ))
        ],
      ),
    );
  }
}
