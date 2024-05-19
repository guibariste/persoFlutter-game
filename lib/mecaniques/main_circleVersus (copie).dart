// import 'package:flutter/animation.dart';
// import 'circle.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:fuck_circle/utils/timer.dart';
// import 'dart:async';

// class MainCircleVersus {
//   final void Function() websoRight;
//   final void Function() websoLeft;
//   final void Function() websoUp;
//   final void Function() websoDown;
//   final void Function() websoStop;
//   final void Function() websoReset;
//   final void Function() websoCharge;
//   late AnimationController _animationController;
//   // late AnimationController _animationControllerVs;

//   double _xPos = 0.0;
//   double _yPos = 0.0;
//   double _xPosVse = 0.0;
//   double _yPosVse = 0.0;
//   double _xDirection = 0.0;
//   double _yDirection = 0.0;
//   double _xDirectionVs = 0.0;
//   double _yDirectionVs = 0.0;
//   double _yposCharge = 0.0;
//   double _yposChargeVs = 0.0;
//   double limit = 0.0;
//   int vie = 10;
//   bool stop = false;
//   bool charging = false;
//   bool chargingVs = false;
//   bool chargingFort = false;
//   bool authChargeForte = true;
//   // bool chargeMod = false;
//   double _speed = 500.0;
//   double _speedVs = 500.0;
//   final Function(double, double) onPositionChangedRect;
//   final Function(double, double) onPositionChangedRectVs;
//   final double screenWidth;
//   final double screenHeight;
//   final double realScreenHeight;
//   double actualXpos = 0.0;
//   double actualYpos = 0.0;
//   bool _isLosingLife =
//       false; // Ajout d'un booléen pour suivre l'état de la perte de vie
//   int _delay = 1000; // Temps i
//   bool mort = false;
//   // MainCircle({required this.onPositionChangedRect, required this.screenWidth});
//   MainCircleVersus({
//     required this.onPositionChangedRect,
//     required this.onPositionChangedRectVs,
//     required this.screenWidth,
//     required this.screenHeight,
//     required this.realScreenHeight,
//     required this.authChargeForte,
//     required this.mort,
//     required this.websoRight,
//     required this.websoLeft,
//     required this.websoUp,
//     required this.websoDown,
//     required this.websoStop,
//     required this.websoReset,
//     required this.websoCharge,
//   });

//   // void init(AnimationController controller, AnimationController controllerVs) {
//   void init(AnimationController controller) {
//     _animationController = controller;
//     // _animationControllerVs = controllerVs;

//     final double leftLimit = 0;
//     final double rightLimit = screenWidth;
//     final double upLimit = 0;
//     final double downLimit = realScreenHeight;
//     final double limit = realScreenHeight / 2;

//     double initialPosX = screenWidth / 2;
//     double initialPosXVs = screenWidth / 2;

//     double initialPosY = realScreenHeight - 100.h;
//     double initialPosYVs = 100.h;
//     _xPos = initialPosX;
//     _yPos = initialPosY;
//     _xPosVse = initialPosXVs;
//     _yPosVse = initialPosYVs;
//     double marge = 20.0;
//     _animationController.addListener(() {
//       _xPos += _xDirection * _animationController.value * _speed;
//       _yPos += _yDirection * _animationController.value * _speed;
//       perteVie();
//       // print(vie);
//       if (_xPos < leftLimit + marge) {
//         _xPos = leftLimit + marge;
//       } else if (_xPos > rightLimit - marge) {
//         _xPos = rightLimit - marge;
//       } else if (_yPos < upLimit + marge) {
//         _yPos = upLimit + marge;
//       } else if (_yPos > downLimit - marge) {
//         _yPos = downLimit - marge;
//       }

//       onPositionChangedRect(_xPos, _yPos);
//       // perteVie();

//       // _animationControllerVs.addListener(() {
//       _xPosVse += _xDirectionVs * _animationController.value * _speedVs;
//       _yPosVse += _yDirectionVs * _animationController.value * _speedVs;

//       if (_xPosVse < leftLimit + marge) {
//         _xPosVse = leftLimit + marge;
//       } else if (_xPosVse > rightLimit - marge) {
//         _xPosVse = rightLimit - marge;
//       } else if (_yPosVse < upLimit + marge) {
//         _yPosVse = upLimit + marge;
//       } else if (_yPosVse > downLimit - marge) {
//         _yPosVse = downLimit - marge;
//       }

//       onPositionChangedRectVs(_xPosVse, _yPosVse);

//       // print(_speedVs);
//       // actualXpos = _xPos;
//       // actualYpos = _yPos;
//       //   });
//     });
//   }

//   void perteVie() {
//     if (_yPos.toInt() >= realScreenHeight - 20.h) {
//       if (!_isLosingLife) {
//         // Si le cercle vient de toucher le bas, commencez à perdre un point de vie
//         _isLosingLife = true;
//         Future.delayed(Duration(milliseconds: 1000), () {
//           if (vie > 0) {
//             vie -= 1;
//           }
//           // print(vie);
//           _isLosingLife = false;

//           if (vie == 0) {
//             mort = true;
//           }
//         });
//       } else {
//         // Si le cercle reste au bas de l'écran, réinitialisez le délai pour perdre un point de vie
//         _delay = 1000;
//       }
//     }
//   }

//   bool checkCollision(double xPos, double yPos, double xPosVs, double yPosVs) {
//     // Logique de vérification de collision ici
//     // Par exemple, vérifiez si les cercles se chevauchent horizontalement et verticalement
//     return (yPos >= yPosVs - 50.0.h && yPos <= yPosVs + 50.0.h) &&
//             (xPos >= xPosVs - 20.0.w && xPos <= xPosVs + 20.0.w) &&
//             charging == true ||
//         chargingVs == true;
//   }

//   bool checkCollisionForte(
//       double xPos, double yPos, double xPosVs, double yPosVs) {
//     return (yPos >= yPosVs - 50.0.h && yPos <= yPosVs + 50.0.h) &&
//         (xPos >= xPosVs - 20.0.w && xPos <= xPosVs + 20.0.w) &&
//         chargingFort == true;
//   }

//   void chargeNormale() {
//     if (!charging) {
//       charging = true;
//       double originalSpeed = _speed;
//       double originalYDirection = _yDirection;
//       _yposCharge = _yPos;
//       _speed = 400.0;
//       _yDirection = -1.2;
//       websoCharge();

//       Future.delayed(Duration(milliseconds: 100), () {
//         _speed = originalSpeed;
//         _yDirection = originalYDirection;

//         charging = false;
//         _yPos = _yposCharge;
//         _animationController.reset();
//         _animationController.forward();
//       });
//     }
//   }

//   void chargeNormaleVs() {
//     if (!chargingVs) {
//       chargingVs = true;
//       double originalSpeed = _speedVs;
//       double originalYDirection = _yDirectionVs;
//       _yposChargeVs = _yPosVse;
//       _speedVs = 400.0;
//       _yDirectionVs = 1.2;

//       Future.delayed(Duration(milliseconds: 100), () {
//         _speed = originalSpeed;
//         _yDirectionVs = originalYDirection;

//         chargingVs = false;
//         _yPosVse = _yposChargeVs;
//         // _animationControllerVs.reset();
//         // _animationControllerVs.forward();
//       });
//     }
//   }

//   void chargeForte() {
//     //------------------------------------------------------------------------

//     //ce sera plutot la fonction charger qui se recharge apres un certain temps
//     //et ce sera celui qui aura appuye avant qui remportera la charge
// //le cercle qui charge ne revient pas tout seul dans sa zone mais il perd de l'energie lorsquil est dans la zone adverse?
//     //-------------------------------------------------------------------------

//     if (!chargingFort && authChargeForte) {
//       chargingFort = true;
//       double originalSpeed = _speed;
//       double originalYDirection = _yDirection;

//       _speed = 400.0;
//       _yDirection = -1.5;

//       Future.delayed(Duration(milliseconds: 100), () {
//         _speed = originalSpeed;
//         _yDirection = originalYDirection;
//         chargingFort = false;
//         _animationController.reset();
//         _animationController.forward();
//         authChargeForte = false;
//       });
//       Future.delayed(Duration(seconds: 10), () {
//         authChargeForte = true;
//         // print("autorise");
//       });
//     }
//   }

//   void moveLeft() {
//     if (!charging) {
//       charging = false;
//       _xDirection = -1.0;
//       _animationController.reset();
//       _animationController.forward();
//       websoLeft();
//     }
//   }

//   void moveRight() {
//     if (!charging) {
//       _xDirection = 1.0;
//       _animationController.reset();
//       _animationController.forward();
//       websoRight();
//     }
//   }

//   void moveUp() {
//     if (!charging) {
//       _yDirection = -1.0;
//       _animationController.reset();
//       _animationController.forward();
//       websoUp();
//     }
//   }

//   void moveDown() {
//     if (!charging) {
//       _yDirection = 1.0;
//       _animationController.reset();
//       _animationController.forward();

//       websoDown();
//     }
//   }

//   void stopMoving() {
//     _xDirection = 0.0;
//     _yDirection = 0.0;

//     // _animationController.stop();
//     stop = true;
//     websoStop();
//   }

//   // void realPosition() {
//   //   print(_xPos);
//   // }

//   void reset() {
//     _xPos = screenWidth / 2;
//     _yPos = realScreenHeight - 100.h;

//     mort = false;
//     vie = 10;
//     websoReset();
//   }

//   void resetVs() {
//     _xPosVse = screenWidth / 2;
//     _yPosVse = 100.h;
//     mort = false;
//     // websoReset;
//   }
//   // void setSpeed(double speed) {

//   //   _speed=speed;

//   // }

//   void moveLeftVs() {
//     _xDirectionVs = 1.0;
//     _speedVs = 500;
//     //  print(screenWidth);

//     // _xDirection = -1.0;
//     _animationController.reset();
//     _animationController.forward();
//     stop = false;
//   }

//   void moveRightVs() {
//     _xDirectionVs = -1.0;
//     _speedVs = 500;

//     _animationController.reset();
//     _animationController.forward();
//     stop = false;
//   }

//   void reculVs() {
//     _yDirectionVs = -1.0;

//     _animationController.reset();
//     _animationController.forward();
//     _speedVs = 800; //a controller
//     stop = false;
//   }

//   void moveUpVs() {
//     _yDirectionVs = 1.0;
//     //  print(screenWidth);
//     _speedVs = 500;
//     // _xDirection = -1.0;
//     _animationController.reset();
//     _animationController.forward();
//   }

//   void moveDownVs() {
//     _yDirectionVs = -1.0;
//     _animationController.reset();
//     _animationController.forward();
//     _speedVs = 500;
//   }

//   void stopMovingVs() {
//     _xDirectionVs = 0.0;
//     _yDirectionVs = 0.0;

//     // _animationController.stop();
//     // stop = true;
//   }

//   int get vies => vie;
// }
