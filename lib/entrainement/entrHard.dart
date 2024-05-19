import 'package:flutter/material.dart';
import 'package:fuck_circle/mecaniques/main_circle.dart';
import 'package:fuck_circle/mecaniques/circle.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuck_circle/utils/timer.dart';
import 'package:fuck_circle/utils/manette.dart';
import 'dart:math';
import 'package:fuck_circle/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fuck_circle/utils/db.dart';
import 'package:fuck_circle/utils/socket.dart';

//ca marche bien apres rajouter des fonctions bonus pr eventuellement rajouter du temps
class EntrHard extends StatefulWidget {
  // final Function? onRestart;
  final double screenWidth;
  final double screenHeight;
  final double topPosition;
  final double bottomPosition;
  final double leftPosition;
  final double rightPosition;
  final double realScreenHeight;
  final double bottomForGame;

  final String pseudo;
  EntrHard({
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

class _PingPongScreenState extends State<EntrHard>
    with TickerProviderStateMixin {
  //---------------INIT----------------------------------
  bool message = false;
  late AnimationController _animationController;
  bool _inGame = false;
  int _secondsRemaining = 60;
  late MainCircle _mainCircle;
  int highestScore = 0;
  bool _timerRunning = false;
  late Circle _circle;
  double _xPosPerso = 0.0;
  double _yPosPerso = 0.0;
  int score = 0;
  CountdownTimer? _countdownTimer;
  // double _screenWidth = 0.0;
  List<Circle> circles = [];
  bool _showWindow = true;
  bool _showWindowEnd = false;
  SocketIoManager socketIoManager = SocketIoManager();
  @override
  void initState() {
    super.initState();
    print('initState() called');
    socketIoManager.initializeSocket();
    if (mounted) updateHighestScoreDiff();

    double largeur = widget.screenWidth;
    double hauteur = widget.bottomForGame;
    double initialPosX = widget.screenWidth / 2;
    double initialPosY = widget.realScreenHeight / 2;
    Circle newCircle = Circle(largeur * 0.2, hauteur / 2, 25, Colors.blue,
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
        // Mettez à jour votre interface utilisateur avec le compte à rebours
        // Par exemple, vous pouvez utiliser un Text pour afficher les secondes restantes
        setState(() {
          _secondsRemaining = secondsRemaining;
        });
      },
      onComplete: () {
        // print("c fini");
        setState(() {
          _showWindowEnd = true;
        });

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
      bottomForGame: widget.bottomForGame,
    );

    _mainCircle.init(_animationController);
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // Restauration de l'état
  //   SharedPreferences.getInstance().then((prefs) {
  //     setState(() {
  //       _xPosPerso = prefs.getDouble('xPosPerso') ?? _screenWidth / 2;
  //       _yPosPerso = prefs.getDouble('yPosPerso') ?? 200.0;
  //       // Restaurez ici d'autres données d'état pertinentes si nécessaire
  //     });
  //   });
  // }

  @override
  void dispose() {
    _animationController.dispose();
    if (_countdownTimer != null && _countdownTimer!.isActive) {
      _countdownTimer!.cancel();
    }
    // SharedPreferences.getInstance().then((prefs) {
    //   prefs.setDouble('xPosPerso', _xPosPerso);
    //   prefs.setDouble('yPosPerso', _yPosPerso);
    //   // Sauvegardez ici d'autres données d'état pertinentes si nécessaire
    // });
    super.dispose();
    socketIoManager.closeSocket();
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
      backgroundColor: const Color.fromARGB(255, 66, 65, 65),
      body: Stack(children: [
        // CustomPainter en expanded sur tout l'écran
        Positioned.fill(
          child: CustomPaint(
            painter: PingPongPainter(
              xPosPerso: _xPosPerso,
              yPosPerso: _yPosPerso,
              circles: circles,
              screenWidth: widget.screenWidth,
            ),
            child: Container(),
          ),
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
              width: buttonWidth,
              child: Container(
                child: ElevatedButton(
                  onPressed: () async {
                    // _countdownTimer?.cancel();
                    // } else {
                    _countdownTimer?.start();
                    updateHighestScoreDiff();
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
                    DatabaseHelper.insertScore(pseudo, score, "entrHard");

                    final data = {
                      'pseudo': pseudo,
                      'score': score,
                      'mode': "entrDifficile",
                    };

                    socketIoManager.sendScore(data);

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
                    DatabaseHelper.insertScore(pseudo, score, "entrHard");
                    final data = {
                      'pseudo': pseudo,
                      'score': score,
                      'mode': "entrDifficile",
                    };

                    socketIoManager.sendScore(data);
                    resetGame();
                    updateHighestScoreDiff();
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
          bottom: 10.h,
          left: largeur / 2 - 90,
          child: Manette(
            moveUp: _mainCircle.moveUp,
            moveDown: _mainCircle.moveDown,
            moveLeft: _mainCircle.moveLeft,
            moveRight: _mainCircle.moveRight,
            stopMoving: _mainCircle.stopMoving,
          ),
        )
      ]),
    );
  }

//----------------fonctions----------------------------

  // Future<void> getHighestScore() async {
  //   int score = await DatabaseHelper.getHighestScore(widget.pseudo, "entrHard");
  //   setState(() {
  //     highestScore = score;
  //   });
  // }
  // Future<void> getHighestScore() async {
  //   socketIoManager.listenForHighestScoreDifficile((message) {
  //     print(message);
  //     setState(() {
  //       highestScore = message;
  //     });
  //   });
  // }

  // void _showTimerDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Démarrer le minuteur'),
  //         content: Text('Êtes-vous sûr de vouloir démarrer le minuteur ?'),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text('Annuler'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               _countdownTimer?.start(); // Démarrer votre minuteur ici
  //               setState(() {
  //                 _showWindow = false; // Cache la fenêtre de démarrage
  //               });
  //               Navigator.of(context).pop(); // Ferme la fenêtre de dialogue
  //             },
  //             child: Text('Démarrer'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
// ... Votre code existant ...

  void updateHighestScoreDiff() async {
    if (mounted) {
      final getScore = {
        'pseudo': widget.pseudo,
        'mode': 'entrDifficile',
      };

      socketIoManager.sendGetHighestScoreDifficile(getScore);

      socketIoManager.scoreDifficile((message) {
        if (mounted) {
          setState(() {
            highestScore = message;
          });
        }
      });
    }
  }

  void resetGame() {
    setState(() {
      score = 0;

      _countdownTimer?.cancel();

      _showWindowEnd = false;
      _showWindow = true;
      positionDepart();
    });
  }

  void positionDepart() {
    setState(() {
      circles.clear(); // Supprime tous les cercles actuels
      _xPosPerso = widget.screenWidth / 2;
      _yPosPerso = widget.realScreenHeight / 2;
      // Crée un nouveau cercle initial
      Circle newCircle = Circle(widget.screenWidth * 0.2,
          widget.realScreenHeight / 2, 25, Colors.blue,
          mainCircle: MainCircle(
            onPositionChangedRect: (x, y) {},
            screenWidth: widget.screenWidth,
            screenHeight: widget.screenHeight,
            realScreenHeight: widget.realScreenHeight,
            bottomForGame: widget.bottomForGame,
          ));
      circles.add(newCircle);
      _mainCircle.reset();
    });
  }

  void checkCirclesForRemoval() {
    for (Circle _circle in circles) {
      if (_circle.shouldRemoveAleatoire(_mainCircle)) {
        // print("aleatoire");
        if (_countdownTimer != null && _countdownTimer!.isActive) {
          score++;
        }
        removeCircle(_circle);
        createRandomCircle(
            widget.screenWidth, widget.bottomForGame, 25, Colors.blue);
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

  void createRandomCircle(
      double screenWidth, double realScreenHeight, double size, Color color) {
    // Utiliser la classe Random pour obtenir des coordonnées aléatoires
    Random random = Random();

    double pourX;
    double pourY;

    do {
      pourX = random.nextDouble();
    } while (pourX <= 0.1 || pourX >= 0.9);

    do {
      pourY = random.nextDouble();
    } while (pourY <= 0.1 || pourY >= 0.9);

    double x = pourX * screenWidth;
    double y = pourY * realScreenHeight;

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
  final List<Circle> circles; // Liste de cercles
  final double screenWidth;
  PingPongPainter({
    required this.xPosPerso,
    required this.yPosPerso,
    required this.circles,
    required this.screenWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // final yPosRect = size.height - 50.0;
    //  final yPosBalle = size.height - 50.0;

    for (Circle circle in circles) {
      canvas.drawCircle(
        Offset(circle.x, circle.y),
        circle.size,
        Paint()..color = circle.color.withOpacity(0.5),
      );
    }

    final paintBarre = Paint()..color = const Color.fromARGB(255, 243, 33, 51);
    canvas.drawCircle(
      Offset(xPosPerso, yPosPerso),
      20.0, // Rayon du cercle
      paintBarre,
    );
  }

  @override
  bool shouldRepaint(PingPongPainter oldDelegate) => true;
}
