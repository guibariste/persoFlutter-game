import 'package:flutter/animation.dart';

// import 'package:fuck_circle/mecaniques/versus.dart';

import 'package:flutter/material.dart';
// import 'dart:ui';

//gerer mieux la mise a jour des pos
//faire que si on veut ravoir le menu ca arrete la partie sinon ca deregle tout
//faire que on ne peut pas retourner l'ecran sinon ca sera trop complique
//styliser

class MainCircleVs {
  late AnimationController _animationController;
  // final PingPongScreenState pingPongScreenState;

  double _xPos = 0;
  double _yPos = 0;
  double _xPosVs = 0;
  double _yPosVs = 0;
  // double _targetXVs = 0;
  // double _targetYVs = 0;
  // double _lerpFactor = 0.1;
  // bool shouldStartInterpolation =
  //     false;

  // late double _xPos;
  // late double _yPos;
  // late double _xPosVs;
  // late double _yPosVs;

  double _xDirection = 0.0;
  double _yDirection = 0.0;
  bool stop = false;
  double _speed = 500.0;
  final Function(double, double) onPositionChangedRect;
  final Function(double, double) onPositionChangedRectVs;
  // final Function(bool) getCreateur;
  final double topForGame;
  final double bottomForGame;
  final double leftPosition;
  final double rightPosition;
  bool createur = false;

  // double actualXpos = 0.0;
  // double actualYpos = 0.0;

  // MainCircle({required this.onPositionChangedRect, required this.screenWidth});
  MainCircleVs({
    required this.onPositionChangedRect,
    required this.onPositionChangedRectVs,
    required this.topForGame,
    required this.bottomForGame,
    required this.leftPosition,
    required this.rightPosition,
    required this.createur,

    // required this.pingPongScreenState,
  });

  void init(AnimationController controller) {
    // Future.delayed(Duration(seconds: 2), () {
    //   shouldStartInterpolation =
    //       true; // Définissez le drapeau pour commencer l'interpolation
    // });
    if (createur) {
      _xPos = leftPosition + rightPosition / 4;
      _yPos = bottomForGame - bottomForGame / 4;
      _xPosVs = rightPosition - rightPosition / 4;
      _yPosVs = bottomForGame - bottomForGame / 4;
    } else {
      _xPos = rightPosition - rightPosition / 4;
      _yPos = bottomForGame - bottomForGame / 4;
      _xPosVs = leftPosition + rightPosition / 4;
      _yPosVs = bottomForGame - bottomForGame / 4;
    }
    _animationController = controller;
    double marge = 20.0;
    _animationController.addListener(() {
      onPositionChangedRect(
          _xPos += _xDirection * _animationController.value * _speed,
          _yPos += _yDirection * _animationController.value * _speed);

      // mettre ici pour delimiter les bords
      // if (_xPos < leftPosition + marge) {
      //   _xPos = leftPosition + marge;
      // } else if (_xPos > rightPosition - marge) {
      //   _xPos = rightPosition - marge;
      // } else if (_yPos < topForGame + marge) {
      //   _yPos = topForGame + marge;
      // } else if (_yPos > bottomForGame - marge) {
      //   _yPos = bottomForGame - marge;
      // }
      if (_xPos < leftPosition + marge) {
        _xPos = rightPosition - marge;
      } else if (_xPos > rightPosition - marge) {
        _xPos = leftPosition + marge;
      } else if (_yPos < topForGame + marge) {
        _yPos = bottomForGame - marge;
      } else if (_yPos > bottomForGame - marge) {
        _yPos = topForGame + marge;
      }
      // if (!stop && shouldStartInterpolation) {
      // if (!stop) {
      //   _xPosVs = lerpDouble(_xPosVs, _targetXVs, _lerpFactor) ?? _xPosVs;
      //   _yPosVs = lerpDouble(_yPosVs, _targetYVs, _lerpFactor) ?? _yPosVs;
      // }
      onPositionChangedRectVs(
          _xPosVs += _xDirection * _animationController.value * _speed,
          _yPosVs += _yDirection * _animationController.value * _speed);
      // print(_xPos);

      if (_xPosVs < leftPosition + marge) {
        _xPosVs = rightPosition - marge;
      } else if (_xPosVs > rightPosition - marge) {
        _xPosVs = leftPosition + marge;
      } else if (_yPosVs < topForGame + marge) {
        _yPosVs = bottomForGame - marge;
      } else if (_yPosVs > bottomForGame - marge) {
        _yPosVs = topForGame + marge;
      }
      // if (_xPosVs < leftPosition + marge) {
      //   _xPosVs = leftPosition + marge;
      // } else if (_xPosVs > rightPosition - marge) {
      //   _xPosVs = rightPosition - marge;
      // } else if (_yPosVs < topForGame + marge) {
      //   _yPosVs = topForGame + marge;
      // } else if (_yPosVs > bottomForGame - marge) {
      //   _yPosVs = bottomForGame - marge;
      // }
    });
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  void moveLeft() {
    _xDirection = -1.0;

    //  print(screenWidth);

    // _xDirection = -1.0;
    _animationController.reset();
    _animationController.forward();
    stop = false;
  }

  // void setPosition(double x, double y) {
  //   // Mettez à jour les variables de position ici
  //   _xPos = x;
  //   _yPos = y;
  // }

  void setPositionVs(double x, double y) {
    // Mettez à jour les variables de position ici
    // _targetXVs = x;
    // _targetYVs = y;
    _xPosVs = x;
    _yPosVs = y;
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
    // print('$_xPos  xposCallsemain_circle');
    _xDirection = 0.0;
    _yDirection = 0.0;

    // _animationController.stop();
    stop = true;
  }

  // void reset() {
  //   _xPos = screenWidth / 2;
  //   _yPos = realScreenHeight / 2;
  // }
  // void setSpeed(double speed) {

  //   _speed=speed;

  // }

  double get xPos => _xPos; //pour recuperer la valeur dans un autre fichier
  double get yPos => _yPos;
  double get xPosVersus =>
      _xPosVs; //pour recuperer la valeur dans un autre fichier
  double get yPosVersus =>
      _yPosVs; //pour recuperer la valeur dans un autre fichier
}
