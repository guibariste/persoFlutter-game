import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

// bien regler la jouabilite
//ajouter un frein?

class JoystickVertical extends StatelessWidget {
  final Function(double, double) onJoystickChange;
  final Function() accelere;
  final Function() freine;
  final Function() normal;

  JoystickVertical({
    required this.onJoystickChange,
    required this.accelere,
    required this.freine,
    required this.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Joystick(
      mode: JoystickMode.vertical,
      listener: (details) {
        if (details.y < -0.5) {
          accelere();
        } else if (details.y > 0.5) {
          freine();
        } else {
          normal();
        }

        // Vous pouvez également appeler la fonction onJoystickChange avec les valeurs x et y du joystick
        onJoystickChange(details.x, details.y);
      },
    );
  }
}
