import 'package:flutter/material.dart';
import 'package:fuck_circle/mecaniques/main_circle.dart';
import 'package:fuck_circle/mecaniques/circle.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuck_circle/utils/timer.dart';
// import 'package:fuck_circle/utils/manette.dart';
import 'package:fuck_circle/utils/manetteBis.dart';
import 'package:fuck_circle/utils/manetteVerticale.dart';

import 'package:fuck_circle/main.dart';
// import 'package:fuck_circle/utils/db.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:fuck_circle/utils/socket.dart';
import 'dart:async';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//ca marche bien apres rajouter des fonctions bonus pr eventuellement rajouter du temps
class PingPongScreen extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final double topPosition;
  final double bottomPosition;
  final double leftPosition;
  final double rightPosition;
  final double realScreenHeight;
  final double bottomForGame;
  final String pseudo;
  PingPongScreen({
    required this.screenWidth,
    required this.screenHeight,
    required this.topPosition,
    required this.bottomPosition,
    required this.leftPosition,
    required this.rightPosition,
    required this.realScreenHeight,
    required this.bottomForGame,
    required this.pseudo,
  });
  @override
  _PingPongScreenState createState() => _PingPongScreenState();
}

class _PingPongScreenState extends State<PingPongScreen>
    with TickerProviderStateMixin {
  //---------------INIT----------------------------------
  ui.Image? backgroundImage; // Ajoutez cette ligne dans votre classe
  double speed = 0;
  Future<void> loadImage() async {
    final ByteData data = await rootBundle.load('assets/image/perso.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final Completer<ui.Image> completer = Completer();

    ui.decodeImageFromList(bytes, (ui.Image img) {
      backgroundImage = img;
      completer.complete(img);
      setState(() {});
    });

    await completer.future;
  }

  // bool _inGame = false;
  bool message = false;
  late AnimationController _animationController;
  int _secondsRemaining = 60; // Add this line
  late MainCircle _mainCircle;
  // bool _timerRunning = false;
  // late Circle _circle;
  double _xPosPerso = 0.0;
  double _yPosPerso = 0.0;
  int score = 0;
  int highestScore = 0;
  // late Timer _timer;
  CountdownTimer? _countdownTimer;
  // double _screenWidth = 0.0;
  List<Circle> circles = [];
  bool _showWindow = true;
  bool _showWindowEnd = false;
  double tailleCercle = 30;
  // SocketIoManager socketIoManager = SocketIoManager();
  // late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    print('initState() called'); // Ajoutez ce message de débogage
    fetchScore();
    loadImage();
    // connectToSocket();
    // socketIoManager.initializeSocket();

    // updateHighestScore();

    // _timer = Timer.periodic(Duration(seconds: 2), (timer) {
    //   updateHighestScore();
    // });

    // DatabaseHelper
    //     .initialize();

    double largeur = widget.screenWidth;
    // print('$largeur  largeur');
    double hauteur = widget.realScreenHeight;
    double initialPosX = widget.screenWidth / 2;
    double initialPosY = widget.realScreenHeight / 2;

    Circle newCircle =
        Circle(largeur * 0.2, hauteur / 2, tailleCercle, Colors.red,
            mainCircle: MainCircle(
              onPositionChangedRect: (x, y) {},
              screenWidth: widget.screenWidth,
              screenHeight: widget.screenHeight,
              realScreenHeight: widget.realScreenHeight,
              bottomForGame: widget.bottomForGame,
            ));
    circles.add(newCircle);
    _xPosPerso = initialPosX;

    _yPosPerso = initialPosY;
    _countdownTimer = CountdownTimer(
      onTick: (secondsRemaining) {
        setState(() {
          _secondsRemaining = secondsRemaining;
        });
      },
      onComplete: () {
        print("c fini");
        _showWindowEnd = true;
        // Le compte à rebours est terminé, vous pouvez faire quelque chose ici
        // Par exemple, afficher un message ou effectuer une action spécifique
      },
    );

    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..addListener(() {
        setState(() {
          // Appeler la fonction checkCirclesForRemoval à chaque mise à jour de l'animation
          checkCirclesForRemoval();
        });
      });
    _mainCircle = MainCircle(
        onPositionChangedRect: (double xPosRect, double ypos) {
          setState(() {
            _xPosPerso = xPosRect;
            _yPosPerso = ypos;

            // newCircle.infoCircle(circles, newCircle, _mainCircle);
          });
        },
        screenWidth: widget.screenWidth,
        screenHeight: widget.screenHeight,
        realScreenHeight: widget.realScreenHeight,
        bottomForGame: widget.bottomForGame);

    _mainCircle.init(_animationController);
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   updateHighestScore();
  // }

  @override
  void dispose() {
    _animationController.dispose();

    // _countdownTimer?.cancel();
    if (_countdownTimer != null && _countdownTimer!.isActive) {
      _countdownTimer!.cancel();
    }
    // SharedPreferences.getInstance().then((prefs) {
    //   prefs.setDouble('xPosPerso', _xPosPerso);
    //   prefs.setDouble('yPosPerso', _yPosPerso);
    //   // Sauvegardez ici d'autres données d'état pertinentes si nécessaire
    // });
    super.dispose();
    // socket.dispose();
    //   socketIoManager.closeSocket();
  }

  //---------------------BUILD---------------------

  @override
  Widget build(BuildContext context) {
    double largeur = widget.screenWidth;
    double hauteur = widget.screenHeight;
    final double buttonWidth = 200.0;
    final double centerX = (widget.screenWidth - buttonWidth) / 2;
    final double topPosition = 70.h;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 56, 56, 56),
      body: Stack(children: [
        // CustomPainter en expanded sur tout l'écran
        Positioned.fill(
          child: CustomPaint(
            painter: PingPongPainter(
              // Remplacez par le chemin de votre image PNG
              xPosPerso: _xPosPerso,
              yPosPerso: _yPosPerso,
              circles: circles, // Si vous avez une liste de cercles
              screenWidth: widget.screenWidth,
              backgroundImage: backgroundImage,
            ),
          ),
          // CustomPaint(
          //   painter: PingPongPainter(
          //     xPosPerso: _xPosPerso,
          //     yPosPerso: _yPosPerso,
          //     circles: circles,
          //     screenWidth: widget.screenWidth,
          //   ),
          //   child: Container(),
          // ),
        ),

        // Timer en haut à gauche
        Positioned(
          top: 16.h,
          left: 16.w,
          child: Text(
            'Temps restant: $_secondsRemaining secondes',
            style: TextStyle(
              color: Colors.white, // Couleur du texte en blanc
            ),
          ),
        ),

        // Score en haut à droite
        Positioned(
          top: 16.h,
          right: 16.w,
          child: Text(
            'SCORE:$score',
            style: TextStyle(
              color: Colors.white, // Couleur du texte en blanc
            ),
          ),
        ),

        if (_showWindow)
          Positioned(
              top: topPosition,
              left: centerX,
              width: buttonWidth, // Définissez la largeur du bouton iciœ
              child: Container(
                child: ElevatedButton(
                  onPressed: () {
                    // _countdownTimer?.cancel();
                    // } else {
                    _countdownTimer?.start();

                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) {
                    //   return MainScreen();
                    // }));
                    // updateHighestScore();

                    setState(() {
                      _showWindow = false; // Cache la fenêtre de démarrage
                    });
                  },
                  child: Text('Démarrer le minuteur'),
                ),
              )),

        if (_showWindowEnd)
          Positioned(
              top: 70.h,
              right: 20.w,
              child: Container(
                child: ElevatedButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String? pseudo = prefs.getString('pseudo');

                    // DatabaseHelper.insertScore(pseudo, score, "entrFacile");
                    final data = {
                      'pseudo': pseudo,
                      'score': score,
                      'mode': "entrFacile",
                    };
                    insertScore();
                    // socketIoManager.sendScore(data);
                    fetchScore();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return MainScreen();
                    }));
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => MainScreen(),
                    //   ),
                    // );
                  },
                  child: Text('Retour à l\'accueil'),
                ),
              )),

        if (_showWindowEnd)
          Positioned(
              top: 70.h,
              left: 20.w,
              child: Container(
                child: ElevatedButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String? pseudo = prefs.getString('pseudo');
                    // DatabaseHelper.insertScore(pseudo, score, "entrFacile");

                    // final data = {
                    //   'pseudo': pseudo,
                    //   'score': score,
                    //   'mode': "entrFacile",
                    // };
                    insertScore();
                    // socketIoManager.sendScore(data);

                    resetGame();
                    fetchScore();
                    // updateHighestScore();
                  },
                  child: Text('Recommencer'),
                ),
              )),

        Positioned(
          top: 40.h,
          left: 20.w,
          child: Text(
            "Meilleur score : $highestScore",
            style: TextStyle(
              color: Colors.white, // Couleur du texte en blanc
            ),
          ),
        ),

        // Manette en bas au centre
        Positioned(
          bottom: 50.h,
          // left: largeur / 2 - 90,
          left: 20.h,
          // child: Manette(
          //   moveUp: _mainCircle.moveUp,
          //   moveDown: _mainCircle.moveDown,
          //   moveLeft: _mainCircle.moveLeft,
          //   moveRight: _mainCircle.moveRight,
          //   stopMoving: _mainCircle.stopMoving,
          // ),
          child: SizedBox(
            width: 100, // Largeur du joystick
            height: 100, // Hauteur du joystick
            child: JoystickWidget(
              onJoystickChange: (double x, double y) {
                // Cette fonction est appelée à chaque changement de position du joystick
                // Vous pouvez l'utiliser pour suivre les valeurs du joystick si nécessaire
              },
              moveUp: _mainCircle.moveUp,
              moveDown: _mainCircle.moveDown,
              moveLeft: _mainCircle.moveLeft,
              moveRight: _mainCircle.moveRight,
              stopMoving: _mainCircle.stopMoving,
              // speed: speed,
            ),
          ),
        ),
        Positioned(
          bottom: 50.h,
          // left: largeur / 2 - 90,
          right: 20.h,

          child: SizedBox(
            width: 100, // Largeur du joystick
            height: 100, // Hauteur du joystick
            child: JoystickVertical(
              onJoystickChange: (double x, double y) {
                // Cette fonction est appelée à chaque changement de position du joystick
                // Vous pouvez l'utiliser pour suivre les valeurs du joystick si nécessaire
              },
              accelere: _mainCircle.increaseSpeed,
              freine: _mainCircle.decreaseSpeed,
              normal: _mainCircle.speedNormal,

              // speed: speed,
            ),
          ),
        ),
        // Positioned(
        //   bottom: 50,
        //   right: 0,
        //   child: GestureDetector(
        //     onTapDown: (_) {
        //       // Utilisez inGame pour conditionner les mouvements
        //       _mainCircle.decreaseSpeed();
        //     },
        //     onTapUp: (_) {
        //       // Utilisez inGame pour conditionner les mouvements
        //       _mainCircle.speedNormal();
        //     },
        //     child: Container(
        //       width: 60,
        //       height: 60,
        //       decoration: BoxDecoration(
        //         color: Colors.blue,
        //         shape: BoxShape.circle,
        //       ),
        //       child: Icon(
        //         FontAwesomeIcons.arrowUp,
        //         color: Colors.white,
        //       ),
        //     ),
        //   ),
        // )
      ]),
    );
  }

// ----------------fonctions----------------------------
  // void _decreaseSpeed() {
  //   setState(() {
  //     // Diminuez la vitesse actuelle du cercle ici
  //     _mainCircle
  //         .decreaseSpeed(); // Appel de la fonction pour diminuer la vitesse
  //   });
  // }

  Future<void> insertScore() async {
    try {
      final response = await http.post(
        // Uri.parse('http://192.168.164.141:8080/insertScore'),
        Uri.parse('http://localhost:8080/getHighestScore'),
        body: json.encode({
          'pseudo': widget.pseudo,
          'mode': 'entrFacile',
          'score': score,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
      } else {
        print('Échec de la requête HTTP avec le code ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP : $e');
    }
  }

  Future<void> fetchScore() async {
    try {
      final response = await http.post(
        // Uri.parse('http://192.168.164.141:8080/getHighestScore'),
        Uri.parse('http://localhost:8080/getHighestScore'),
        body: json.encode({
          'pseudo': widget.pseudo,
          'mode': 'entrFacile',
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        // print(jsonData['highest_score']);
        setState(() {
          highestScore = jsonData['highest_score'];
        });
      } else {
        print('Échec de la requête HTTP avec le code ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP : $e');
    }
  }

  void resetGame() {
    setState(() {
      score = 0;

      _countdownTimer?.cancel();

      _showWindowEnd = false;
      _showWindow = true;
      // _mainCircle.reset();
      positioneDepart();
    });
  }

  void positioneDepart() {
    setState(() {
      circles.clear(); // Supprime tous les cercles actuels
      _xPosPerso = widget.screenWidth / 2;
      _yPosPerso = widget.realScreenHeight / 2;
      // Crée un nouveau cercle initial
      Circle newCircle = Circle(
        widget.screenWidth * 0.2,
        widget.realScreenHeight / 2,
        tailleCercle,
        Color.fromARGB(255, 246, 4, 40),
        mainCircle: MainCircle(
            onPositionChangedRect: (x, y) {},
            screenWidth: widget.screenWidth,
            screenHeight: widget.screenHeight,
            realScreenHeight: widget.realScreenHeight,
            bottomForGame: widget.bottomForGame),
      );
      circles.add(newCircle);
      _mainCircle.reset();
    });
  }

  void checkCirclesForRemoval() {
    for (Circle _circle in circles) {
      if (_circle.shouldRemoveLeft(_mainCircle)) {
        print("gagne");
        removeCircle(_circle);
        createNewCircle(widget.screenWidth * 0.8, widget.realScreenHeight / 2,
            tailleCercle, Color.fromARGB(255, 244, 4, 4));
        if (_countdownTimer != null && _countdownTimer!.isActive) {
          // print("ca compte");
          score++;
        } else {
          // print("ca compte pas");
        }
      }
      if (_circle.shouldRemoveRight(_mainCircle)) {
        // print("gagne");
        removeCircle(_circle);
        createNewCircle(widget.screenWidth * 0.2, widget.realScreenHeight / 2,
            tailleCercle, Color.fromARGB(255, 239, 6, 9));
        if (_countdownTimer != null && _countdownTimer!.isActive) {
          // print("ca compte");
          score++;
        } else {
          // print("ca compte pas");
        }
      }
    }
  }

  void createNewCircle(double x, double y, double size, Color color) {
    setState(() {
      Circle newCircle = Circle(
        x,
        y,
        size,
        color,
        mainCircle: _mainCircle,
      );
      circles.add(newCircle);
    });
  }

  // Supprimez la fonction removeCircle
  void removeCircle(Circle circle) {
    setState(() {
      circles.remove(circle);
    });
  }
}

class PingPongPainter extends CustomPainter {
  final double xPosPerso;
  final double yPosPerso;
  final List<Circle> circles;
  final double screenWidth;
  final ui.Image? backgroundImage; // Ajoutez cette ligne

  PingPongPainter({
    required this.xPosPerso,
    required this.yPosPerso,
    required this.circles,
    required this.screenWidth,
    required this.backgroundImage, // Ajoutez cette ligne
  });

  @override
  void paint(Canvas canvas, Size size) {
    // if (backgroundImage != null) {
    //   canvas.drawImage(backgroundImage!, Offset.zero, Paint());
    // }
    final paintBarre = Paint();
    final double radius = 20.0;
    final double diameter = radius * 2;
    for (Circle circle in circles) {
      canvas.drawCircle(
        Offset(circle.x, circle.y),
        circle.size,
        Paint()..color = circle.color.withOpacity(0.5),
      );
    }

    if (backgroundImage != null) {
      final Rect imageRect = Rect.fromCenter(
        center: Offset(xPosPerso, yPosPerso),
        width: 60, // Largeur de l'image
        height: 60, // Hauteur de l'image
      );

      canvas.drawImageRect(
        backgroundImage!,
        Rect.fromPoints(
            Offset(0, 0),
            Offset(backgroundImage!.width.toDouble(),
                backgroundImage!.height.toDouble())),
        imageRect,
        Paint(),
      );
    } else {
      // Si l'image n'est pas encore chargée, vous pouvez utiliser une couleur de secours
      final paintBarre = Paint()..color = Color.fromARGB(255, 45, 8, 191);
      canvas.drawCircle(
        Offset(xPosPerso, yPosPerso),
        20.0,
        paintBarre,
      );
    }
    // final paintBarre = Paint()..color = Color.fromARGB(255, 45, 8, 191);
    // canvas.drawCircle(
    //   Offset(xPosPerso, yPosPerso),
    //   20.0,
    //   paintBarre,
    // );
  }

  @override
  bool shouldRepaint(PingPongPainter oldDelegate) => true;
}

// class PingPongPainter extends CustomPainter {
//   final double xPosPerso;
//   final double yPosPerso;
//   final List<Circle> circles; // Liste de cercles
//   final double screenWidth;

//   PingPongPainter({
//     required this.xPosPerso,
//     required this.yPosPerso,
//     required this.circles,
//     required this.screenWidth,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     for (Circle circle in circles) {
//       canvas.drawCircle(
//         Offset(circle.x, circle.y),
//         circle.size,
//         Paint()..color = circle.color.withOpacity(0.5),
//       );
//     }
//     paintImage(
//         canvas: canvas,
//         rect: Rect.fromLTRB(0, 0, 200, 200),
//         image: image,
//         fit: BoxFit.cover);

//     final paintBarre = Paint()..color = Color.fromARGB(255, 45, 8, 191);
//     canvas.drawCircle(
//       Offset(xPosPerso, yPosPerso),
//       20.0, // Rayon du cercleR
//       paintBarre,
//     );
//   }

//   @override
//   bool shouldRepaint(PingPongPainter oldDelegate) => true;
// }
