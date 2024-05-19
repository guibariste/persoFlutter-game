import 'package:flutter/material.dart';
// import 'pong_screen.dart';
import 'main_circleVersus.dart';
// import 'dart:async';

class CircleVs {
  double x;
  double y;
  double size;
  Color color;
  MainCircleVs mainCircle; // Ajoutez ce paramètre
  MainCircleVs mainCircleVs;
  CircleVs(this.x, this.y, this.size, this.color,
      {required this.mainCircle, required this.mainCircleVs});

  bool shouldRemoveAleatoire(MainCircleVs mainCircle) {
    // Mettez ici toutes les conditions que vous souhaitez vérifier

    bool condition1 = mainCircle.xPos.toInt() >= x - 10 &&
        mainCircle.xPos.toInt() <= x + 10 &&
        mainCircle.yPos.toInt() >= y - 10 &&
        mainCircle.yPos.toInt() <= y + 10 &&
        mainCircle.stop;
    ;
    return condition1;
  }

  bool shouldRemoveAleatoireVs(MainCircleVs mainCircleVs) {
    // Mettez ici toutes les conditions que vous souhaitez vérifier

    bool condition2 = mainCircle.xPosVersus.toInt() >= x - 10 &&
        mainCircleVs.xPosVersus.toInt() <= x + 10 &&
        mainCircleVs.yPosVersus.toInt() >= y - 10 &&
        mainCircleVs.yPosVersus.toInt() <= y + 10 &&
        mainCircleVs.stop;
    ;
    return condition2;
  }

  // void infoCircle(List<Circle> circles, newCircle, MainCircle mainCircle) {
  //   Circle newCircle;
  //   for (newCircle in circles) {
  //     print(
  //       newCircle.x,
  //     );
  //     print(mainCircle.xPos.toInt());

  //   }
  // }
}
