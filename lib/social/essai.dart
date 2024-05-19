import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class MyGame extends StatefulWidget {
  @override
  _MyGameState createState() => _MyGameState();
}

class _MyGameState extends State<MyGame> {
  double centerX = 200;
  double centerY = 200;
  double circleX = 200;
  double circleY = 200;
  double radius = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Circle Joystick Example'),
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            double dx = details.localPosition.dx - centerX;
            double dy = details.localPosition.dy - centerY;
            double angle = atan2(dy, dx);
            double distance = min(radius, sqrt(dx * dx + dy * dy));
            circleX = centerX + distance * cos(angle);
            circleY = centerY + distance * sin(angle);
          });
        },
        onPanEnd: (details) {
          // Reset the circle to the center when the touch ends.
          setState(() {
            circleX = centerX;
            circleY = centerY;
          });
        },
        child: Center(
          child: Stack(
            children: [
              Container(
                width: 2 * radius,
                height: 2 * radius,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
              ),
              Positioned(
                left: circleX - radius,
                top: circleY - radius,
                child: Container(
                  width: 2 * radius,
                  height: 2 * radius,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
