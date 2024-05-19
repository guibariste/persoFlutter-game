import 'package:flutter/material.dart';
// import 'pong_screen.dart';
import 'main_circle.dart';
// import 'dart:async';

class Circle {
  double x;
  double y;
  double size;
  Color color;
  MainCircle mainCircle; // Ajoutez ce paramètre
  double marge = 15;
  Circle(this.x, this.y, this.size, this.color, {required this.mainCircle});

  bool shouldRemoveLeft(MainCircle mainCircle) {
    // Mettez ici toutes les conditions que vous souhaitez vérifier

    bool condition1 = mainCircle.xPos.toInt() >= x - marge &&
        mainCircle.xPos.toInt() <= x + marge &&
        x > 0 &&
        x < mainCircle.screenWidth / 2 &&
        mainCircle.yPos.toInt() >= y - marge &&
        mainCircle.yPos.toInt() <= y + marge &&
        mainCircle.stop;
    ;
    return condition1;
  }

  bool shouldRemoveRight(MainCircle mainCircle) {
    // Mettez ici toutes les conditions que vous souhaitez vérifier
    bool condition1 = mainCircle.xPos.toInt() >= x - 10 &&
        mainCircle.xPos.toInt() <= x + marge &&
        mainCircle.yPos.toInt() >= y - marge &&
        mainCircle.yPos.toInt() <= y + marge &&
        x > mainCircle.screenWidth / 2 &&
        x < mainCircle.screenWidth &&
        mainCircle.stop;
    // bool condition2 = ... // Autre condition

    return condition1;
  }

  bool shouldRemoveAleatoire(MainCircle mainCircle) {
    // Mettez ici toutes les conditions que vous souhaitez vérifier

    bool condition1 = mainCircle.xPos.toInt() >= x - 10 &&
        mainCircle.xPos.toInt() <= x + marge &&
        mainCircle.yPos.toInt() >= y - marge &&
        mainCircle.yPos.toInt() <= y + marge &&
        mainCircle.stop;
    ;
    return condition1;
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
