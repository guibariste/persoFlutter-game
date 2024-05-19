// import 'package:flutter/material.dart';
// import 'main_circleVersus.dart';
// import 'circle.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import 'package:fuck_circle/utils/manette.dart';
// import 'package:fuck_circle/main.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// // import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:fuck_circle/utils/db.dart';
// import 'dart:async';



// class Versus extends StatefulWidget {
//   final double screenWidth;
//   final double screenHeight;
//   final double topPosition;
//   final double bottomPosition;
//   final double leftPosition;
//   final double rightPosition;
//   final double realScreenHeight;
//   final String pseudo;
//   Versus({
//     required this.screenWidth,
//     required this.screenHeight,
//     required this.topPosition,
//     required this.bottomPosition,
//     required this.leftPosition,
//     required this.rightPosition,
//     required this.realScreenHeight,
//     required this.pseudo,
//   });
//   @override
//   _PingPongScreenState createState() => _PingPongScreenState();
// }

// class _PingPongScreenState extends State<Versus> with TickerProviderStateMixin {
//   //---------------INIT----------------------------------
//   // final WebSocketChannel channel =
//   //     WebSocketChannel.connect(Uri.parse('ws://localhost:8090/ws'));
//   // WebSocketChannel.connect(Uri.parse('wss://echo.websocket.events'));
//   bool _shouldColorMainCircle = false;
//   late AnimationController _animationController;
//   // late AnimationController _animationControllerVs;
//   String invitedFriendPseudo = ""; // Pseudo de l'ami qui a envoyé l'invitation
//   String roomName = ""; // Nom de la room
//   bool _isVersus = false;
//   late MainCircleVs _mainCircle;
//   late MainCircleVs _mainCircleVs;
//   late Ticker _ticker;
//   bool _showInvitation = false;
//   String hote = "";
//   double _xPosVs = 0.0;
//   double _yPosVs = 0.0;
//   double _xPosPerso = 0.0;
//   double _yPosPerso = 0.0;
//   int vie = 10;
//   bool mort = false;
//   late Timer _timer;
//   // bool authChargeForte = true;
//   int score = 0;
//   double percentage = 40.0; // La valeur en pourcentage
//   // double _screenWidth = 0.0;
//   List<Circle> circles = [];
//   late IO.Socket socket;
//   List<String> _amis = []; // Liste pour stocker les amis
//   @override
//   void initState() {
//     super.initState();
//     connectToSocket();

//     double largeur = widget.screenWidth;
//     double hauteur = widget.realScreenHeight;
//     double initialPosX = largeur / 2;
//     double initialPosY = hauteur - 100.h;
//     // double initialPosXVs = largeur / 2;
//     // double initialPosYVs = 100.h;

//     MainCircle(
//       onPositionChangedRect: (x, y) {},
//       onPositionChangedRectVs: (x, y) {},
//       screenWidth: widget.screenWidth,
//       screenHeight: widget.screenHeight,
//       realScreenHeight: widget.realScreenHeight,
//       authChargeForte: true,
//       mort: mort,
//       websoRight: _goRight,
//       websoLeft: _goLeft,
//       websoUp: _goUp,
//       websoDown: _goDown,
//       websoStop: _goStop,
//       websoReset: _goReset,
//       websoCharge: _goCharge,
//     );

//     // _xPosVs = initialPosXVs;

//     // _yPosVs = initialPosYVs;
//     _xPosPerso = initialPosX;

//     _yPosPerso = initialPosY;

//     _animationController = AnimationController(
//       duration: const Duration(seconds: 10),
//       vsync: this,
//     )..addListener(() {
//         // print(_mainCircle
//         //     .authChargeForte); //il faut faire un bouton qui change de couleur pour quon visualise le timer
//         // print(_mainCircle.vie);

//         // if (vie == 0) resetGame();

//         setState(() {
//           if (_mainCircle.checkCollision(
//               _xPosPerso, _yPosPerso, _xPosVs, _yPosVs)) {
//             _shouldColorMainCircle =
//                 true; //pour faire changer de couleur a la collision
//             _mainCircle.stopMoving();
//             print("avant collision");
//             Future.delayed(Duration(milliseconds: 500), () {
//               _shouldColorMainCircle = false;
//               print("aprescollision");
//             });
//           }

//           if (_mainCircle.checkCollisionForte(
//                   _xPosPerso, _yPosPerso, _xPosVs, _yPosVs) &&
//               _mainCircle.chargingFort == true) {
//             _mainCircle.stopMoving();
//             _mainCircleVs.reculVs();
//           }

//           // mort = _mainCircle.morts;
//         });
//       });
//     _mainCircle = MainCircleVersus(
//       onPositionChangedRect: (double xPosRect, double ypos) {
//         // setState(() {
//         _xPosPerso = xPosRect;
//         _yPosPerso = ypos;
//         // });
//       },
//       onPositionChangedRectVs: (double xPosRect, double ypos) {},
//       screenWidth: widget.screenWidth,
//       screenHeight: widget.screenHeight,
//       realScreenHeight: widget.realScreenHeight,
//       authChargeForte: true,
//       mort: mort,
//       websoRight: _goRight,
//       websoLeft: _goLeft,
//       websoUp: _goUp,
//       websoDown: _goDown,
//       websoStop: _goStop,
//       websoReset: _goReset,
//       websoCharge: _goCharge,
//     );
//     _mainCircleVs = MainCircleVersus(
//       onPositionChangedRectVs: (double xPosRecte, double ypose) {
//         // setState(() {
//         _xPosVs = xPosRecte;
//         _yPosVs = ypose;
//         // });
//       },
//       onPositionChangedRect: (double xPosRect, double ypos) {},
//       screenWidth: widget.screenWidth,
//       screenHeight: widget.screenHeight,
//       realScreenHeight: widget.realScreenHeight,
//       authChargeForte: true,
//       mort: mort,
//       websoRight: _goRight,
//       websoLeft: _goLeft,
//       websoUp: _goUp,
//       websoDown: _goDown,
//       websoStop: _goStop,
//       websoReset: _goReset,
//       websoCharge: _goCharge,
//     );

//     _animationControllerVs = AnimationController(
//       duration: const Duration(seconds: 10),
//       vsync: this,
//     )..addListener(() {
//         setState(() {
//           print("$_yPosVs :vs");
//         });
//       });

//     _mainCircle = MainCircleVersus(
//       onPositionChangedRect: (double xPosRect, double ypos) {
//         setState(() {
//           _xPosPerso = xPosRect;
//           _yPosPerso = ypos;
//         });
//       },
//       onPositionChangedRectVs: (double xPosRect, double ypos) {},
//       screenWidth: widget.screenWidth,
//       screenHeight: widget.screenHeight,
//       realScreenHeight: widget.realScreenHeight,
//       authChargeForte: true,
//       mort: mort,
//       websoRight: _goRight,
//       websoLeft: _goLeft,
//       websoUp: _goUp,
//       websoDown: _goDown,
//       websoStop: _goStop,
//       websoReset: _goReset,
//       websoCharge: _goCharge,
//     );
//     _mainCircleVs = MainCircleVersus(
//       onPositionChangedRectVs: (double xPosRect, double ypos) {
//         setState(() {
//           _xPosVs = xPosRect;
//           _yPosVs = ypos;
//         });
//       },
//       onPositionChangedRect: (double xPosRect, double ypos) {},
//       screenWidth: widget.screenWidth,
//       screenHeight: widget.screenHeight,
//       realScreenHeight: widget.realScreenHeight,
//       authChargeForte: true,
//       mort: mort,
//       websoRight: _goRight,
//       websoLeft: _goLeft,
//       websoUp: _goUp,
//       websoDown: _goDown,
//       websoStop: _goStop,
//       websoReset: _goReset,
//       websoCharge: _goCharge,
//     );

//     _mainCircle.init(_animationController, _animationControllerVs);
//     _mainCircleVs.init(
//       _animationController,
//       _animationControllerVs,
//     );
//     _animationController.forward();
//     _animationControllerVs.forward();
//     _mainCircle.init(_animationController);
//     _mainCircleVs.init(_animationController);
//     _animationController.forward();
//     _timer = Timer.periodic(Duration(seconds: 5), (timer) {
//       socket.emit('realPos', {'x': _xPosPerso, 'y': _yPosPerso});
//     });
//     _ticker = createTicker((elapsed) {
//       setState(() {
//         // print(_mainCircle.mort);
//         if (_mainCircle.mort) {
//           print("mort");
//           _mainCircle.reset();
//         }
//         vie = _mainCircle.vies;
//       });
//     });
//     _ticker.start();
//   }

//   @override
//   void dispose() {
//     // channel.sink.close();
//     _animationController.dispose();
//     // _animationControllerVs.dispose();
//     socket.dispose();
//     super.dispose();
//     _timer.cancel();
//   }

//   //---------------------BUILD---------------------

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _isVersus
//           ? buildVersus()
//           : _buildLancement(), // Affiche le profil ou l'alerte en fonction de l'état de connexion
//     );
//   }

//   @override
//   Widget buildVersus() {
//     return Scaffold(
//         backgroundColor: Colors.black,
//         body: Stack(
//           children: [
//             Column(
//               children: [
//                 Expanded(
//                   child: CustomPaint(
//                     painter: PingPongPainter(
//                       xPosPerso: _xPosPerso,
//                       yPosPerso: _yPosPerso,
//                       xPosVs: _xPosVs,
//                       yPosVs: _yPosVs,
//                       circles: circles,
//                       screenWidth: widget.screenWidth,
//                       screenHeight: widget.realScreenHeight,
//                     ),
//                     child: Container(),
//                   ),
//                 ),
//                 SizedBox(height: 60.h),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Vos autres widgets ici
//                     Manette(
//                       moveUp: _mainCircle.moveUp,
//                       moveDown: _mainCircle.moveDown,
//                       moveLeft: _mainCircle.moveLeft,
//                       moveRight: _mainCircle.moveRight,
//                       stopMoving: _mainCircle.stopMoving,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             Positioned(
//               bottom: 20.h,
//               left: 100.w,
//               child: Container(
//                 width: 60.0,
//                 height: 60.0,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.blue,
//                 ),
//                 child: ElevatedButton(
//                   onPressed: () {
//                     _mainCircle.chargeNormale();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     primary: Colors.transparent,
//                     onPrimary: Colors.transparent,
//                   ),
//                   child: Icon(
//                     Icons.arrow_circle_up_outlined,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 20.h,
//               right: 100.w,
//               child: Container(
//                 width: 60.0,
//                 height: 60.0,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   //  color: _mainCircle.authChargeForte ? Colors.blue : Colors.red,
//                   color: _shouldColorMainCircle
//                       ? const Color.fromARGB(255, 243, 33, 72)
//                       : Color.fromARGB(255, 94, 94, 205),
//                 ),
//                 child: ElevatedButton(
//                   onPressed: () {
//                     _mainCircle.chargeForte();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     primary: Colors.transparent,
//                     onPrimary: Colors.transparent,
//                   ),
//                   child: Icon(
//                     Icons.arrow_circle_up_outlined,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//                 top: 20.h,
//                 left: 20.w,
//                 child: Text(
//                   widget.pseudo + ': $score',
//                   style: TextStyle(
//                     color: Color.fromRGBO(238, 244, 244,
//                         1), // Changer la couleur du texte en noir
//                     // fontSize: 20.0,
//                   ),
//                 )),
//             Positioned(
//                 top: 20.h,
//                 right: 20.w,
//                 child: Text(
//                   'adversaire : score',
//                   style: TextStyle(
//                     color: Color.fromRGBO(238, 244, 244,
//                         1), // Changer la couleur du texte en noir
//                     // fontSize: 20.0,
//                   ),
//                 )),
//             Positioned(
//               top: 40.h,
//               left: 10.w,
//               child: Container(
//                 width: 100.w,
//                 height: 20.h,
//                 child: LinearProgressIndicator(
//                   value: (vie * 10) / 100, // Utilisez la valeur en pourcentage
//                   backgroundColor: Colors.grey,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//                 ),
//               ),
//             ),
//             Positioned(
//               top: 40.h,
//               right: 10.w,
//               child: Container(
//                 width: 100.w,
//                 height: 20.h,
//                 child: LinearProgressIndicator(
//                   value: (vie * 10) / 100, // Utilisez la valeur en pourcentage
//                   backgroundColor: Colors.grey,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//                 ),
//               ),
//             ),
//             // Positioned(
//             //     bottom: 300,
//             //     right: 180.w,
//             //     child: Container(
//             //       child: ElevatedButton(
//             //         onPressed: () {
//             //           _essa();
//             //         },
//             //         child: Text('Essai'),
//             //       ),
//             //     ))
//           ],
//         ));
//   }

//   Widget _buildLancement() {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Column(
//         children: [
//           ElevatedButton(
//             onPressed: () async {
//               _amis = await DatabaseHelper.getFriends(widget.pseudo);
//               setState(() {});
//             },
//             child: Text('Essai'),
//           ),
//           SizedBox(height: 20),
//           Expanded(
//             child: ListView.builder(
//               itemCount: _amis.length,
//               itemBuilder: (context, index) {
//                 String ami = _amis[index];
//                 return ListTile(
//                   title: Text(ami),
//                   textColor: Colors.white,
//                   trailing: ElevatedButton(
//                     onPressed: () {
//                       inviteFriend(_amis[index]);
//                     },
//                     child: Text('Inviter'),
//                   ),
//                 );
//               },
//             ),
//           ),
//           if (_showInvitation)
//             AlertDialog(
//               title: Text('Invitation'),
//               content:
//                   Text('Vous avez été invité par $hote à rejoindre une salle.'),
//               actions: [
//                 ElevatedButton(
//                   onPressed: () {
//                     // Accepter l'invitation - Ajoutez votre logique ici
//                     acceptInvitation(hote, widget.pseudo);
//                     _showInvitation = false;
//                     _isVersus = true;
//                   },
//                   child: Text('Accepter'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     refuseInvitation(hote, widget.pseudo);
//                     _showInvitation = false;
//                   },
//                   child: Text('Refuser'),
//                 ),
//               ],
//             ),
//         ],
//       ),
//     );
//   }

//   void connectToSocket() {
//     socket = IO.io('http://localhost:8080', <String, dynamic>{
//       'transports': ['websocket'],
//     });
//     // socket = IO.io('http://51.103.26.79:8080', <String, dynamic>{
//     //   'transports': ['websocket'],
//     // });
//     socket.on('connect', (_) {
//       print('Connected to server');
//       joinRoomWithPseudo(widget.pseudo); // Envoyer le pseudo après la connexion
//     });

//     // Écouter les messages entrants
//     // socket.on('message', (message) {
//     //   print(
//     //       'Received message: $message'); // Afficher le message reçu (Bonjour {pseudo})
//     // });
//     socket.on('invitation', (message) {
//       setState(() {
//         _showInvitation = true;
//         hote = message;
//       });
//       print(message);
//     });
//     socket.on('invitationAccepted', (message) {
//       print(message);
//       if (message == true) {
//         _isVersus = true;
//       } else {
//         print("le joueur a refuse");

//         //revenir a la page principale
//       }
//     });
//     socket.on('realPosVs', (message) {
//       double x = message['x'].toDouble(); // Convertir 'x' en double
//       double y = message['y'].toDouble(); // Convertir 'y' en double
//       double middleX = widget.screenWidth / 2;
//       double middleY = widget.realScreenHeight / 2;
//       // print(middleY);
// // Calcule la position miroir de _mainCircle par rapport au milieu

//       // setState(() {
//       _xPosVs = middleX + (middleX - x);
//       _yPosVs = middleY + (middleY - y);
//       // _xPosVs = x;
//       // _yPosVs = y;
//       // });
//       // la position se met bien a jour mais qd on recommence ca reprend la position de depart
//       print('Valeur de x: $_xPosVs');
//       print('Valeur de y: $_yPosVs');
//     });
//     socket.on('direction', (message) {
//       if (message == "right") {
//         _mainCircleVs.moveRightVs();
//       } else if (message == "stop") {
//         _mainCircleVs.stopMovingVs();
//       } else if (message == "left") {
//         _mainCircleVs.moveLeftVs();
//       } else if (message == "up") {
//         _mainCircleVs.moveUpVs();
//       } else if (message == "down") {
//         _mainCircleVs.moveDownVs();
//       } else if (message == "reset") {
//         _mainCircleVs.resetVs();
//       } else if (message == "charge") {
//         _mainCircleVs.chargeNormaleVs();
//       }
//     });
//   }

//   // void sendMessageToVs(String pseudo) {
//   //   socket.emit('direction', 'up');
//   // }
//   // void sendPseudo(String pseudo) {
//   //   socket.emit('pseudo', {'pseudo': pseudo});
//   // }

//   // void sendMessage(String message) {
//   //   socket.emit('message', {'message': message});
//   // }
//   void acceptInvitation(String hote, String invite) {
//     // Émettre l'événement 'acceptInvitation' avec l'hôte et l'invité
//     socket.emit('acceptInvitation', {
//       'hote': hote,
//       'invite': invite,
//     });
//   }

//   void refuseInvitation(String hote, String invite) {
//     // Émettre l'événement 'acceptInvitation' avec l'hôte et l'invité
//     socket.emit('refuseInvitation', {
//       'hote': hote,
//       'invite': invite,
//     });

//     //revenir a la page principale
//   }

//   void inviteFriend(String friendPseudo) {
//     // Émettre l'événement 'inviteFriend' avec le pseudonyme de l'ami
//     socket.emit('inviteFriend', {'invite': friendPseudo});
//   }

//   void joinRoomWithPseudo(String pseudo) {
//     socket.emit('pseudo', {'pseudo': pseudo});
//   }

//   void _goRight() {
//     socket.emit('direction', 'right');
//   }

//   void _goLeft() {
//     socket.emit('direction', 'left');
//   }

//   void _goUp() {
//     socket.emit('direction', 'up');
//   }

//   void _goDown() {
//     socket.emit('direction', 'down');
//   }

//   void _goStop() {
//     socket.emit('direction', 'stop');
//   }

//   void _goReset() {
//     socket.emit('direction', 'reset');
//   }

//   void _goCharge() {
//     socket.emit('direction', 'charge');
//   }
// }

// //----------------fonctions----------------------------

// class PingPongPainter extends CustomPainter {
//   final double xPosPerso;
//   final double yPosPerso;
//   final double xPosVs;
//   final double yPosVs;
//   final List<Circle> circles; // Liste de cercles
//   final double screenWidth;
//   final double screenHeight;
//   PingPongPainter({
//     required this.xPosPerso,
//     required this.yPosPerso,
//     required this.xPosVs,
//     required this.yPosVs,
//     required this.circles,
//     required this.screenWidth,
//     required this.screenHeight,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final double barHeight = 2.0.h;
//     final double barWidth = screenWidth;
//     final double xPos = 0;
//     final double yPos = screenHeight;

//     final paintBarreGreen = Paint()..color = Color.fromARGB(255, 33, 243, 54);
//     final paintBarreblue = Paint()..color = Color.fromARGB(255, 49, 54, 196);
//     canvas.drawCircle(
//       Offset(xPosPerso, yPosPerso),
//       20.0, // Rayon du cercle
//       paintBarreGreen,
//     );
//     canvas.drawCircle(
//       Offset(xPosVs, yPosVs),
//       20.0, // Rayon du cercle
//       paintBarreblue,
//     );
//   }

//   @override
//   bool shouldRepaint(PingPongPainter oldDelegate) => true;
// }
