//  boutons_screen.dart
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Manette extends StatelessWidget {
  final VoidCallback moveUp;
  final VoidCallback moveDown;
  final VoidCallback moveLeft;
  final VoidCallback moveRight;
  final VoidCallback stopMoving;

  Manette({
    required this.moveUp,
    required this.moveDown,
    required this.moveLeft,
    required this.moveRight,
    required this.stopMoving,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTapDown: (_) {
                    // Utilisez inGame pour conditionner les mouvements
                    moveUp();
                  },
                  onTapUp: (_) {
                    // Utilisez inGame pour conditionner les mouvements
                    stopMoving();
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      FontAwesomeIcons.arrowUp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTapDown: (_) => moveLeft(),
                  onTapUp: (_) => stopMoving(),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      FontAwesomeIcons.arrowLeft,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 60,
                ), // Espace entre les boutons left et right
                GestureDetector(
                  onTapDown: (_) => moveRight(),
                  onTapUp: (_) => stopMoving(),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      FontAwesomeIcons.arrowRight,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTapDown: (_) => moveDown(),
                  onTapUp: (_) => stopMoving(),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      FontAwesomeIcons.arrowDown,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
