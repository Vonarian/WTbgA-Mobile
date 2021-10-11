import 'dart:math' as math; // import this

import 'package:flutter/material.dart';

import 'custom_shape.dart';

class ReceivedMessageScreen extends StatelessWidget {
  final String? message;
  final String? chatSender;
  final dynamic style;
  const ReceivedMessageScreen({
    Key? key,
    this.message,
    this.style,
    this.chatSender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messageTextGroup = Flexible(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(math.pi),
          child: CustomPaint(
            painter: CustomShape(Colors.grey[300]),
          ),
        ),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Column(
              children: [
                Text(chatSender!, style: style),
                Text(
                  message!,
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ],
    ));

    return Padding(
      padding: const EdgeInsets.only(right: 50.0, left: 18, top: 10, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          const SizedBox(height: 30),
          messageTextGroup,
        ],
      ),
    );
  }
}
