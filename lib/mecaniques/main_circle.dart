import 'package:flutter/animation.dart';
import 'package:fuck_circle/entrainement/entrFacile.dart';
import 'circle.dart';

// import 'pong_screen.dart';

class MainCircle {
  late AnimationController _animationController;
  double _xPos = 0.0;
  double _yPos = 0.0;
  double _xDirection = 0.0;
  double _yDirection = 0.0;
  bool stop = false;
  double _speed = 1000.0;
  final Function(double, double) onPositionChangedRect;
  final double screenWidth;
  final double screenHeight;
  final double realScreenHeight;
  final double bottomForGame;

  double actualXpos = 0.0;
  double actualYpos = 0.0;

  // MainCircle({required this.onPositionChangedRect, required this.screenWidth});
  MainCircle({
    required this.onPositionChangedRect,
    required this.screenWidth,
    required this.screenHeight,
    required this.realScreenHeight,
    required this.bottomForGame,
  });

  void init(AnimationController controller) {
    _animationController = controller;

    final double leftLimit = 0;
    final double rightLimit = screenWidth;
    final double upLimit = 0;
    final double downLimit = bottomForGame; //a definir refaire la limite
    double initialPosX = screenWidth / 2;
    // double initialPosY = screenHeight / 2;
    double initialPosY = realScreenHeight / 2;
    _xPos = initialPosX;
    _yPos = initialPosY;
    double marge = 20.0;
    _animationController.addListener(() {
      _xPos += _xDirection * _animationController.value * _speed;
      _yPos += _yDirection * _animationController.value * _speed;

      if (_xPos < leftLimit + marge) {
        _xPos = leftLimit + marge;
      } else if (_xPos > rightLimit - marge) {
        //ici plutot mettre stopbarre pour eviter les bugs
        _xPos = rightLimit - marge;
      } else if (_yPos < upLimit + marge) {
        //ici plutot mettre stopbarre pour eviter les bugs
        _yPos = upLimit + marge;
      } else if (_yPos > downLimit - marge) {
        //ici plutot mettre stopbarre pour eviter les bugs
        _yPos = downLimit - marge;
      }

      onPositionChangedRect(_xPos, _yPos);
      actualXpos = _xPos;
      actualYpos = _yPos;

      // print(_xPos);
    });
  }

  void decreaseSpeed() {
    _speed = 500.0; // Par exemple, diminuez la vitesse de 100 units

    // Mettez à jour la durée de l'animation en fonction de la nouvelle vitesseR
  }

  void increaseSpeed() {
    _speed = 2000.0; // Par exemple, diminuez la vitesse de 100 units

    // Mettez à jour la durée de l'animation en fonction de la nouvelle vitesseR
  }

  void speedNormal() {
    _speed = 1000.0; // Par exemple, diminuez la vitesse de 100 units

    // Mettez à jour la durée de l'animation en fonction de la nouvelle vitesseR
  }

  void moveLeft() {
    _xDirection = -1.0;

    //  print(screenWidth);

    // _xDirection = -1.0;
    _animationController.reset();
    _animationController.forward();
    stop = false;
  }

  void moveRight() {
    _xDirection = 1.0;

    _animationController.reset();
    _animationController.forward();
    stop = false;
  }

  void moveUp() {
    _yDirection = -1.0;
    //  print(screenWidth);

    // _xDirection = -1.0;
    _animationController.reset();
    _animationController.forward();
    stop = false;
  }

  void moveDown() {
    _yDirection = 1.0;
    _animationController.reset();
    _animationController.forward();
    stop = false;
  }

  void stopMoving() {
    _xDirection = 0.0;
    _yDirection = 0.0;

    // _animationController.stop();
    stop = true;
  }

  void reset() {
    _xPos = screenWidth / 2;
    _yPos = realScreenHeight / 2;
  }
  // void setSpeed(double speed) {

  //   _speed=speed;

  // }

  double get xPos =>
      actualXpos; //pour recuperer la valeur dans un autre fichier
  double get yPos =>
      actualYpos; //pour recuperer la valeur dans un autre fichier
}
