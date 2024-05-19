// import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fuck_circle/mecaniques/main_circleVersus.dart';
import 'package:fuck_circle/mecaniques/circleVs.dart';
import 'package:fuck_circle/utils/manette.dart';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:fuck_circle/utils/timerVersus.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuck_circle/social/amis.dart';
import 'package:http/http.dart' as http;
import 'package:fuck_circle/main.dart';
//faire pas de bords cote pr le versus(idee faire un handicap possible pr une duree avoir les bords quelques secondes)
//une manette en totale cercle?2 manettes?
//toute la logique pr creer partie fonctionne bien
//faire le lissage majpos

//pour la logique en ligne hors ligne faire juste qd lutilisateur est ou nest pas ds la page versus?a voir si c neccessaire
//garder la logique pr si il est ds la page versus mais pas sur lappli

//le probleme se regle en evitant les positions d'initialisation avant de mettre a jour

class Versus extends StatefulWidget {
  final double topForGame;
  final double bottomForGame;
  final double leftPosition;
  final double rightPosition;
  final String pseudo;

  final ValueChanged<bool> onGameStatusChanged;

  Versus({
    required this.onGameStatusChanged,
    required this.topForGame,
    required this.bottomForGame,
    required this.leftPosition,
    required this.rightPosition,
    required this.pseudo,
  });

  @override
  PingPongScreenState createState() => PingPongScreenState();
}

class PingPongScreenState extends State<Versus> with TickerProviderStateMixin {
  //---------------INIT----------------------------------

  late AnimationController _animationController;
  bool _reponseRecommencer = false;
  // bool _reponseRecommencerVs = false;

  late MainCircleVs _mainCircle;
  late MainCircleVs _mainCircleVs;
  AmisState amis = AmisState();
  // MainCircleVs? _mainCircle;
  // MainCircleVs? _mainCircleVs;
  late CircleVs _circle;
  // List<CircleVs> circles = [];
  int _secondsRemaining = 120;
  CountdownTimerVersus? _countdownTimer;
  // late Circle _circle;
  late IO.Socket socket;
  double _xPosPerso = 0;
  double _yPosPerso = 0;
  double _xPosVs = 0;
  double _yPosVs = 0;
  bool createVs = false;
  bool _inGame = false;
  bool _isVersus = false;
  bool _createur = false; // Déclaration de la variable statique
  bool boutonLancement = true;
  bool _invite = false;
  bool droitBouger = false;
  bool _clearPartie = false;
  String _vs = "";
  bool _showInvitation = false;
  String hote = "";
  String messageRecommencer = "";
  String messageAttente = "";
  int scorePerso = 0;
  int scoreVs = 0;
  List<Map<String, dynamic>> _amis = []; // Liste pour stocker les amis
  late Timer _timer;
  bool _finGame = false;
  List<String> receivedMessages = []; // Liste des messages reçus
  bool isRandomCircleCreated = false;
  Random random = Random();
  List<CircleVs> circles = [];
  // bool droitTimer = false;
  bool _isAnimating = false;
  bool canIncScore = false;
  bool _recommencer = false;
  bool _acceptedPartie = false;

  void initializeGame() {
    double posInitX = widget.leftPosition + widget.rightPosition / 4;
    double posInitXVs = widget.rightPosition - widget.rightPosition / 4;

    // print(widget.leftPosition);

    CircleVs newCircle = CircleVs(
        widget.rightPosition / 2, widget.bottomForGame / 2, 25, Colors.blue,
        mainCircle: MainCircleVs(
          onPositionChangedRect: (x, y) {},
          onPositionChangedRectVs: (x, y) {},
          topForGame: widget.topForGame,
          bottomForGame: widget.bottomForGame,
          leftPosition: widget.leftPosition,
          rightPosition: widget.rightPosition,
          createur: _createur,

          // pingPongScreenState: PingPongScreenState(),
        ),
        mainCircleVs: MainCircleVs(
          onPositionChangedRect: (x, y) {},
          onPositionChangedRectVs: (x, y) {},
          topForGame: widget.topForGame,
          bottomForGame: widget.bottomForGame,
          leftPosition: widget.leftPosition,
          rightPosition: widget.rightPosition,
          createur: _createur,

          // pingPongScreenState: PingPongScreenState(),
        ));

    circles.add(newCircle);

    _mainCircle = MainCircleVs(
      onPositionChangedRect: (double xPosRect, double ypos) {
        // if (mounted)
        setState(() {
          _xPosPerso = xPosRect;
          _yPosPerso = ypos;

          // newCircle.infoCircle(circles, newCircle, _mainCircle);
        });
      },
      onPositionChangedRectVs: (x, y) {},
      topForGame: widget.topForGame,
      bottomForGame: widget.bottomForGame,
      leftPosition: widget.leftPosition,
      rightPosition: widget.rightPosition,
      createur: _createur,
    );

    _mainCircleVs = MainCircleVs(
      onPositionChangedRectVs: (double xPosRecte, double ypose) {
        // if (mounted)
        setState(() {
          _xPosVs = xPosRecte;
          _yPosVs = ypose;

          // newCircle.infoCircle(circles, newCircle, _mainCircle);
        });
      },
      onPositionChangedRect: (x, y) {},
      topForGame: widget.topForGame,
      bottomForGame: widget.bottomForGame,
      leftPosition: widget.leftPosition,
      rightPosition: widget.rightPosition,
      createur: _createur,
    );

    _mainCircle.init(_animationController);
    _mainCircleVs.init(_animationController);

    _timer = Timer.periodic(Duration(milliseconds: 5000), (timer) {
      // udp();

      if (_xPosPerso != posInitX && _xPosPerso != posInitXVs) //indispensable
        socket.emit('realPos', {
          'x': _xPosPerso,
          'y': _yPosPerso,
          'largeur': widget.rightPosition,
          'hauteur': widget.bottomForGame
        });
    });
  }

  @override
  void initState() {
    super.initState();
    initSansValeur();

    connectToSocket();
    sendPseudo(widget.pseudo);

    print("init");
    timer();

    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..addListener(() {
        checkCirclesForRemoval();
      });
    // _animationController.reset();
    // if (_reponseRecommencer == true && _reponseRecommencerVs == true) {
    //   print("ca commence");
    // }
  }

  @override
  void dispose() {
    super.dispose();
    socket.disconnect();

    if (_countdownTimer != null && _countdownTimer!.isActive) {
      _countdownTimer!.cancel();
    }
  }

  //---------------------BUILD---------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isVersus
          ? buildVersus()
          : _buildLancement(), // Affiche le profil ou l'alerte en fonction de l'état de connexion
    );
  }

  // @override
  Widget buildVersus() {
    final double rightPosition = widget.rightPosition;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 57, 57, 57),
      body: Stack(children: [
        // CustomPainter en expanded sur tout l'écran
        Positioned.fill(
          child: CustomPaint(
            painter: PingPongPainter(
              xPosPerso: _xPosPerso,
              yPosPerso: _yPosPerso,
              xPosVs: _xPosVs,
              yPosVs: _yPosVs,
              circles: circles,
              rightPosition: widget.rightPosition,
            ),
            // child: Container(),
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.pseudo,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                ),
              ),
              Text(
                'Score: $scorePerso',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        // Affichage du "_vs" en haut à droite
        Positioned(
          top: 10,
          right: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _vs,
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                ),
              ),
              Text(
                'Score:$scoreVs',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              Text(
                ' $_secondsRemaining ',
                style: TextStyle(
                  color: Colors.white, // Couleur du texte en blanc
                ),
              ),
            ],
          ),
        ),
        // Positioned(

        //    child: Text(
        //       ' $_secondsRemaining ',
        //       style: TextStyle(
        //         color: Colors.white, // Couleur du texte en blanc
        //       ),
        //     ),
        // ),
        if (_finGame)
          Positioned(
              top: 150,
              right: 0,
              left: 100,
              child: Container(
                child: ElevatedButton(
                  onPressed: () {
                    if (mounted)
                      setState(() {
                        _recommencer = true;
                      });
                    envoiRecommencer();

                    // _startGame();
                  },
                  child: Text('recommencer'),
                ),
              )),
        if (_finGame)
          Positioned(
              top: 150,
              right: 100,
              left: 0,
              child: Container(
                width: 100.w,
                child: ElevatedButton(
                  onPressed: () {
                    if (mounted)
                      setState(() {
                        _reponseRecommencer = false;
                      });
                    // _resetGame();
                    // envoiRecommencer();
                    socket.disconnect();
                    // _animationController.reset();

                    // dispose();
                    // circles.clear();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return MainScreen();
                    }));
                  },
                  child: Text('Accueil'),
                ),
              )),
        if (_recommencer)
          Positioned(
            top: 200.h,
            right: 100,
            left: 100,
            child: Container(
              child: Text(
                '$messageRecommencer',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18 // Couleur du texte en blanc
                    ),
              ),
            ),
          ),
        if (_createur && boutonLancement)
          Positioned(
              top: 50,
              right: 120,
              left: 120,
              child: Container(
                child: ElevatedButton(
                  onPressed: () {
                    // _startGame();
                    _countdownTimer?.start();

                    envoiDebut();
                    if (mounted)
                      setState(() {
                        boutonLancement = false;
                      });

                    // socket.emit('realPos', {'x': _xPosPerso, 'y': _yPosPerso});
                  },
                  child: Text('Commencer'),
                ),
              )),

        Positioned(
          bottom: 10,
          left: rightPosition / 2 - 90,
          child: Manette(
            moveUp: () {
              if (!droitBouger) {
                print("veuillez attendre le debut");
              } else {
                _mainCircle.moveUp();
                socketUp();
              } // Appeler la fonction socketRight() lorsque le bouton "up" est pressé.
            },
            moveDown: () {
              if (!droitBouger) {
                print("veuillez attendre le debut");
              } else {
                _mainCircle.moveDown();
                socketDown();
              } //
            },
            moveLeft: () {
              if (!droitBouger) {
                print("veuillez attendre le debut");
              } else {
                _mainCircle.moveLeft();
                socketLeft();
              } //
            },
            moveRight: () {
              if (!droitBouger) {
                print("veuillez attendre le debut");
              } else {
                _mainCircle.moveRight();
                socketRight();
              } //
            },
            stopMoving: () {
              if (!droitBouger) {
                print("veuillez attendre le debut");
              } else {
                _mainCircle.stopMoving();
                socketStop();
              } //
            },
          ),
        )
      ]),
    );
  }

  Widget _buildLancement() {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 76, 76, 76),
      body: Column(
        children: [
          Text(
            "Vous pouvez inviter vos amis en duel:",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // _amis = await DatabaseHelper.getFriends(widget.pseudo);
              getFriends(widget.pseudo);
            },
            child: Text('Voir mes Amis'),
          ),
          SizedBox(height: 20),
          Expanded(
              child: ListView.builder(
            itemCount: _amis.length,
            itemBuilder: (context, index) {
              String ami = _amis[index]['pseudo'];
              String enLigne = _amis[index]['enLigne'];
              return ListTile(
                title: Text(
                  ami,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                trailing: enLigne == '1'
                    ? ElevatedButton(
                        onPressed: () {
                          inviteFriend(ami);
                        },
                        child: Text('Inviter'),
                      )
                    : Text(
                        'Hors ligne'), // Affiche "Hors ligne" si enLigne est 0
              );
            },
          )),
          Text(
            "$messageAttente",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          if (_showInvitation)
            AlertDialog(
              title: Text('Invitation'),
              content: Text(
                  'Vous avez été invité par $hote à rejoindre une partie.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // Accepter l'invitation - Ajoutez votre logique ici
                    acceptInvitation(hote, widget.pseudo);
                    _showInvitation = false;
                    _isVersus = true;
                  },
                  child: Text('Accepter'),
                ),
                ElevatedButton(
                  onPressed: () {
                    refuseInvitation(hote, widget.pseudo);
                    _showInvitation = false;
                  },
                  child: Text('Refuser'),
                ),
              ],
            ),
        ],
      ),
    );
  }

//----------------fonctions----------------------------
  void envoiScoreVersus(pseudo, pseudoVs, score, scoreVs) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/envoiScoreVersus'),
        // Uri.parse('http://192.168.164.141:8080/getAmis'),
        body: json.encode({
          'pseudo': pseudo,
          'pseudoVs': pseudoVs,
          'score': score,
          'scoreVs': scoreVs,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data['message']);
      } else {
        print('Échec de la requête HTTP avec le code ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP : $e');
    }
  }

  void initSansValeur() {
    _mainCircle = MainCircleVs(
      onPositionChangedRect: (x, y) {
        setState(() {
          _xPosPerso = x;
          _yPosPerso = y;

          // newCircle.infoCircle(circles, newCircle, _mainCircle);
        });
      },
      onPositionChangedRectVs: (x, y) {},
      topForGame: widget.topForGame,
      bottomForGame: widget.bottomForGame,
      leftPosition: widget.leftPosition,
      rightPosition: widget.rightPosition,
      createur: _createur,
    );

    _mainCircleVs = MainCircleVs(
      onPositionChangedRectVs: (x, y) {
        setState(() {
          _xPosVs = x;
          _yPosVs = y;

          // newCircle.infoCircle(circles, newCircle, _mainCircle);
        });
      },
      onPositionChangedRect: (x, y) {},
      topForGame: widget.topForGame,
      bottomForGame: widget.bottomForGame,
      leftPosition: widget.leftPosition,
      rightPosition: widget.rightPosition,
      createur: _createur,
    );
  }

  void connectToSocket() {
    // socket = IO.io('http://192.168.164.141:8080', <String, dynamic>{
    //   'transports': ['websocket'],
    // });
    socket = IO.io('http://localhost:8080', <String, dynamic>{
      'transports': ['websocket'],
    });
    socket.on('connect', (_) {});
    // socket.on('reconnect', (_) {
    //   // Code à exécuter lorsque la connexion est rétablie
    //   socket.emit('sendPseudo', {
    //     'pseudo': widget.pseudo,
    //   });
    // });

    socket.on('directionVs', (message) {
      if (message == "right") {
        _mainCircleVs.moveRight();
      } else if (message == "stop") {
        _mainCircleVs.stopMoving();
      } else if (message == "left") {
        _mainCircleVs.moveLeft();
      } else if (message == "up") {
        _mainCircleVs.moveUp();
      } else if (message == "down") {
        _mainCircleVs.moveDown();
      }
    });
    socket.on('realPosVs', (message) {
      double x = message['x'].toDouble(); // Convertir 'x' en double
      double y = message['y'].toDouble(); // Convertir 'y' en double
      double hauteur = message['hauteur'].toDouble();
      double largeur = message['largeur'].toDouble();
      double finaleX = (x / largeur) * widget.rightPosition;
      double finaleY = (y / hauteur) * widget.bottomForGame;
      // print('$finaleX   finalex');
      // print('$x   x');
      // Mettre à jour la position de _mainCircleVs directement ici
      _mainCircleVs.setPositionVs(finaleX, finaleY);
    });

    socket.on('invitation', (message) {
      if (mounted)
        setState(() {
          _showInvitation = true;
          hote = message;
          setState(() {
            messageAttente = "";
          });
        });
      // print(message);
    });
    socket.on('debutPartie', (message) {
      // resetPosition();
      droitBouger = true;
      initializeGame();
      if (!_createur && mounted) {
        setState(() {
          canIncScore = true;
        });
        _countdownTimer?.start();
      }
    });
    //  socket.on('pseudo', (message) {
    //   if (!_createur) {
    //     _countdownTimer?.start();
    //   }
    // });

    socket.on('recommencer', (message) {
      if (message['reponse'] == true && !_clearPartie) {
        if (mounted)
          setState(() {
            _createur = message['createur'];
            _acceptedPartie = true;
            _recommencer = false;
          });
        _resetGame();

        // initializeGame();
      }
      // else {
      //   print("non tu viens juste de clear la partie");
      // }
      //c bon fo faire la logique pr recommencer
    });
    socket.on('invitationPerime', (message) {
      if (message['invite']) {
        if (mounted)
          setState(() {
            _showInvitation = false;
            messageAttente = (message['message']);
          });
      }
      if (!message['invite']) {
        Future.delayed(Duration(seconds: 10), () {
          setState(() {
            messageAttente = "";
          });
        });
        setState(() {
          messageAttente = (message['message']);
        });
      }
    });
    socket.on('recommencerPerime', (message) {
      print(message['message']);
      _recommencer = true;

      //la il faut mettre une condition pr que ca le fasse pas tt le temps

      setState(() {
        _clearPartie = true;
        messageRecommencer = message['message'];
        _acceptedPartie = false;
        // _clearPartie = true;
      });
    });

    socket.on('invitationAccepted', (message) {
      // print(message['hote']);
      // if (message['accept'] == false) {
      //   setState(() {
      //     messageAttente = (message['message']);
      //   });
      // } else {
      _startGame();
      _clearPartie = false;

      if (message['hote'] == true) {
        if (mounted)
          setState(() {
            _isVersus = true;
            _createur = true;
          });
      }

      // if (_createur) {
      //   if (mounted)
      if (_createur) {
        // initializeGame();
        // setState(() {
        // _createur = true;
        _vs = message['pseudo'];

        // _xPosPerso = widget.leftPosition + widget.rightPosition / 4;
        _xPosPerso = widget.leftPosition + widget.rightPosition / 4;
        _yPosPerso = widget.bottomForGame - widget.bottomForGame / 4;
        _xPosVs = widget.rightPosition - widget.rightPosition / 4;
        _yPosVs = widget.bottomForGame - widget.bottomForGame / 4;
        // });
      } else if (!_createur) {
        // initializeGame();

        // setState(() {
        _vs = message['pseudo'];
        _xPosPerso = widget.rightPosition - widget.rightPosition / 4;
        _yPosPerso = widget.bottomForGame - widget.bottomForGame / 4;
        _xPosVs = widget.leftPosition + widget.rightPosition / 4;
        _yPosVs = widget.bottomForGame - widget.bottomForGame / 4;
        // });
      }
    });

    socket.on('invitationRefused', (message) {
      if (message['hote'] == true) {
        if (mounted)
          Future.delayed(Duration(seconds: 10), () {
            setState(() {
              messageAttente = "";
            });
          });
        setState(() {
          _isVersus = false;
          messageAttente = message['message'];
        });
      } else {
        if (mounted)
          setState(() {
            _showInvitation = false;
          });
      }
    });

    socket.on('removeCircleVs', (message) {
      if (canIncScore) {
        setState(() {
          scoreVs += 1;
        });
      }
      List<CircleVs> copyOfCircles = List.from(circles);
      for (CircleVs _circle in copyOfCircles) {
        removeCircle(_circle);
      }
      // if (message['creerCercle'] == true && _createur == true) {
      //   createRandomCircle(
      //       widget.rightPosition, widget.bottomForGame, 25, Colors.blue);
      // }
    });
    socket.on('posCircleVs', (message) {
      double x = message['x']; // Convertir 'x' en double
      double y = message['y']; // Convertir 'y' en double
      double hauteur = message['hauteur'].toDouble();
      double largeur = message['largeur'].toDouble();
      double finaleX = (x / largeur) * widget.rightPosition;
      double finaleY = (y / hauteur) * widget.bottomForGame;

      createCircleVs(
          finaleX, finaleY, 25, Colors.blue); //visiblement probleme ici
    });

    socket.on('disconnect', (_) {});
    socket.connect();
  }

  void socketUp() {
    socket.emit('direction', "up");
  }

  void envoiRecommencer() {
    if (!_clearPartie) {
      setState(() {
        _reponseRecommencer = true;
      });

      if (_acceptedPartie == false) {
        setState(() {
          messageRecommencer = "en attente de l'accord de l'adversaire";
        });
      } else {
        setState(() {
          messageRecommencer = "";
        });
      }

      socket.emit('envoiRecommencer', {
        'pseudo': widget.pseudo,
        'createur': _createur,
        'reponse': _reponseRecommencer
      });
    } else {
      if (mounted) {
        setState(() {
          messageRecommencer =
              "La Partie n'est plus disponible veuillez en creer une nouvelle!";
        });
      }
    }
  }

  void envoiDebut() {
    droitBouger = true;
    initializeGame();
    // resetPosition();
    setState(() {
      canIncScore = true;
    });
    socket.emit('debut', true);
  }

  void socketRight() {
    socket.emit('direction', "right");
  }

  void socketLeft() {
    socket.emit('direction', "left");
  }

  void socketDown() {
    socket.emit('direction', "down");
  }

  void socketStop() {
    socket.emit('direction', "stop");
  }

  void _startGame() {
    // Code pour commencer le jeu
    if (mounted)
      setState(() {
        _inGame = true;
        _isVersus = true;
      });
    widget.onGameStatusChanged(true); // Appel lorsque le jeu commence
  }

  // void resetPosition() {
  //   if (_createur && mounted) {
  //     setState(() {
  //       // _xPosPerso = widget.leftPosition + widget.rightPosition / 4;
  //       _xPosPerso = widget.leftPosition + widget.rightPosition / 4;
  //       _yPosPerso = widget.bottomForGame - widget.bottomForGame / 4;
  //       _xPosVs = widget.rightPosition - widget.rightPosition / 4;
  //       _yPosVs = widget.bottomForGame - widget.bottomForGame / 4;
  //       // });
  //     });
  //   } else if (!_createur && mounted) {
  //     setState(() {
  //       _xPosPerso = widget.rightPosition - widget.rightPosition / 4;
  //       _yPosPerso = widget.bottomForGame - widget.bottomForGame / 4;
  //       _xPosVs = widget.leftPosition + widget.rightPosition / 4;
  //       _yPosVs = widget.bottomForGame - widget.bottomForGame / 4;
  //     });
  //   }
  // }

  void _resetGame() {
    if (mounted)
      setState(() {
        canIncScore = false;
        _inGame = true;
        scorePerso = 0;
        scoreVs = 0;
        _isVersus = true;
        _finGame = false;
        boutonLancement = true;
        _secondsRemaining = 30;
        timer();
        circles.clear();
        //vider les cercles
      });
    widget.onGameStatusChanged(true);

    if (_createur) {
      // if (mounted)
      //   setState(() {
      _vs = _vs;
      _xPosPerso = widget.leftPosition + widget.rightPosition / 4;
      _yPosPerso = widget.bottomForGame - widget.bottomForGame / 4;
      _xPosVs = widget.rightPosition - widget.rightPosition / 4;
      _yPosVs = widget.bottomForGame - widget.bottomForGame / 4;
      // });
    } else if (!_createur) {
      // if (mounted)
      //   setState(() {
      _vs = _vs;
      _xPosPerso = widget.rightPosition - widget.rightPosition / 4;
      _yPosPerso = widget.bottomForGame - widget.bottomForGame / 4;
      _xPosVs = widget.leftPosition + widget.rightPosition / 4;
      _yPosVs = widget.bottomForGame - widget.bottomForGame / 4;
      // });
    }
  }

  void timer() {
    _countdownTimer = CountdownTimerVersus(
      onTick: (secondsRemaining) {
        if (mounted)
          setState(() {
            _secondsRemaining = secondsRemaining;
          });
      },
      onComplete: () {
        _stopGame();
        if (mounted)
          setState(() {
            droitBouger = false;
            _finGame = true;
            _acceptedPartie = false;

            // _droitRecommencer = true;
            // messageRecommencer = "";
          });
        if (_createur) {
          envoiScoreVersus(widget.pseudo, _vs, scorePerso, scoreVs);
        }

        // Le compte à rebours est terminé, vous pouvez faire quelque chose ici
        // Par exemple, afficher un message ou effectuer une action spécifique
      },
    );
  }

  void _stopGame() {
    // Code pour commencer le jeu
    if (mounted)
      setState(() {
        canIncScore = false;
        _inGame = false;
      });
    widget.onGameStatusChanged(false); // Appel lorsque le jeu commence
  }

  void sendPseudo(String pseudo) {
    socket.emit('pseudo', {'pseudo': pseudo});
  }

  void sendMessage(String message) {
    socket.emit('message', {'message': message});
  }

  void acceptInvitation(String hote, String invite) {
    // Émettre l'événement 'acceptInvitation' avec l'hôte et l'invité
    socket.emit('acceptInvitation', {
      'hote': hote,
      'invite': invite,
    });
    if (mounted)
      setState(() {
        _isVersus = true;
      });
    _startGame();
  }

  void refuseInvitation(String hote, String invite) {
    if (mounted)
      setState(() {
        _showInvitation = false;
      });

    // Émettre l'événement 'acceptInvitation' avec l'hôte et l'invité
    socket.emit('refuseInvitation', {
      'hote': hote,
      'invite': invite,
    });
  }

  void inviteFriend(String friendPseudo) {
    // Émettre l'événement 'inviteFriend' avec le pseudonyme de l'ami
    socket.emit('inviteFriend', {'invite': friendPseudo});
    if (mounted)
      setState(() {
        messageAttente = "En attente de la reponse";
      });
  }

  // void joinRoomWithPseudo(String pseudo) {
  //   socket.emit('pseudo', {'pseudo': pseudo});
  // }

  void envoiCircleVs(double x, double y) {
    socket.emit('envoiCircleVs', {
      'x': x,
      'y': y,
      'largeur': widget.rightPosition,
      'hauteur': widget.bottomForGame
    });
  }

  void removecircleVs() {
    socket.emit('removeCircle', "");
  }

  void checkCirclesForRemoval() {
    for (CircleVs _circle in circles) {
      if (_circle.shouldRemoveAleatoire(_mainCircle)) {
        if (canIncScore) {
          setState(() {
            scorePerso += 1;
          });
        }

        removeCircle(_circle);
        removecircleVs();

        createRandomCircle(
            widget.rightPosition, widget.bottomForGame, 25, Colors.blue);
      }
    }
  }

  void getFriends(pseudo) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/getAmis'),
        // Uri.parse('http://192.168.164.141:8080/getAmis'),
        body: json.encode({
          'pseudo': pseudo,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        for (var ami in data['amis']) {
          print('Ami: ${ami['pseudo']}, En ligne: ${ami['enLigne']}');
        }
        if (mounted)
          setState(() {
            _amis = List<Map<String, dynamic>>.from(data['amis']);
          });
      } else {
        print('Échec de la requête HTTP avec le code ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP : $e');
    }
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

    double x = pourX * widget.rightPosition;
    double y = pourY * widget.bottomForGame;

    setState(() {
      CircleVs newCircle = CircleVs(x, y, size, color,
          mainCircle: _mainCircle, mainCircleVs: _mainCircleVs);
      circles.add(newCircle);
    });
    envoiCircleVs(x, y);
  }

  void createCircleVs(double x, double y, double size, Color color) {
    if (mounted)
      setState(() {
        CircleVs newCircle = CircleVs(x, y, size, color,
            mainCircle: _mainCircle, mainCircleVs: _mainCircleVs);
        circles.add(newCircle);
      });
  }

  // Supprimez la fonction removeCircle
  void removeCircle(CircleVs circle) {
    if (mounted)
      setState(() {
        circles.remove(circle);
      });
  }

  bool getCreateur() {
    return _createur;
  }
}

class PingPongPainter extends CustomPainter {
  final double xPosPerso;
  final double yPosPerso;
  final double xPosVs;
  final double yPosVs;
  final List<CircleVs> circles; // Liste de cercles
  final double rightPosition;

  PingPongPainter({
    required this.xPosPerso,
    required this.yPosPerso,
    required this.xPosVs,
    required this.yPosVs,
    required this.circles,
    required this.rightPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintBarre = Paint()..color = const Color.fromARGB(255, 243, 33, 51);
    final paintBarre2 = Paint()..color = Color.fromARGB(255, 37, 33, 243);

    for (CircleVs circle in circles) {
      canvas.drawCircle(
        Offset(circle.x, circle.y),
        circle.size,
        Paint()..color = circle.color.withOpacity(0.5),
      );
    }

    canvas.drawCircle(
      Offset(xPosPerso, yPosPerso),
      20.0, // Rayon du cercle
      paintBarre,
    );
    canvas.drawCircle(
      Offset(xPosVs, yPosVs),
      20.0, // Rayon du cercle
      paintBarre2,
    );
  }

  @override
  bool shouldRepaint(PingPongPainter oldDelegate) => true;
}
