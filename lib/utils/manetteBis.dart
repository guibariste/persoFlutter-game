import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

// bien regler la jouabilite
//ajouter un frein?

class JoystickWidget extends StatelessWidget {
  final Function(double, double) onJoystickChange;
  final Function() moveUp;
  final Function() moveDown;
  final Function() moveLeft;
  final Function() moveRight;
  final Function() stopMoving;
  // double speed;

  JoystickWidget({
    required this.onJoystickChange,
    required this.moveUp,
    required this.moveDown,
    required this.moveLeft,
    required this.moveRight,
    required this.stopMoving,
    // required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return Joystick(
      mode: JoystickMode.all,
      listener: (details) {
        if (details.y < -0.2) {
          moveUp(); // Appel de la fonction de déplacement vers le haut
        } else if (details.y > 0.2) {
          // Le joystick est déplacé vers le bas

          moveDown(); // Appel de la fonction de déplacement vers le bas
        }
        if (details.x < -0.2) {
          // Le joystick est déplacé vers la gauche

          moveLeft(); // Appel de la fonction de déplacement vers la gauche
        }
        // if (details.x < 0 && details.x > -0.5) {
        //   // Le joystick est déplacé vers la gauche
        //   speed = 500;
        //   moveLeft(); // Appel de la fonction de déplacement vers la gauche
        // }
        else if (details.x > 0.2) {
          print("Direction: Droite");
          moveRight(); // Appel de la fonction de déplacement vers la droite
        } else if (details.x == 0 && details.y == 0) {
          stopMoving(); // Appel de la fonction d'arrêt du mouvement
        }

        // Vous pouvez également appeler la fonction onJoystickChange avec les valeurs x et y du joystick
        onJoystickChange(details.x, details.y);
      },
    );
  }
}
