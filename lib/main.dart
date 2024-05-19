import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'formulaires/connexion.dart';
import 'formulaires/deconnexion.dart';
import 'formulaires/inscription.dart';
import 'mecaniques/versus.dart';
import 'utils/styles.dart';
// import 'utils/image.dart';
import 'social/amis.dart';
import 'social/profil.dart';
import 'entrainement/entrHard.dart';
import 'entrainement/entrFacile.dart';
import 'homePage.dart';
import 'dart:convert';
import 'social/essai.dart';

import 'dart:async';

import 'package:http/http.dart' as http;

//faire un bouton pr switcher manette ds ts les modes

//lenvoi hors ligne ne fonctionne pas
//enlever le parefeu sur ma connexion wifi pr tester en meilleur debit
// //sur tel limage defaut napparait pas pr les profilext
// //faire plus souvent des majstate pr tout
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(400, 640),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Your App Title',
          theme: ThemeData(
            //   //   colorScheme: ColorScheme.highContrastLight(),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: raisedButtonStyle,
            ),
            inputDecorationTheme: myInputDecorationTheme,
          ),
          home: MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  bool _inGame = false;
  int _currentIndex = 0;
  bool showSubMenu = false;
  bool _createur = false;
  double screenHeight = 0;
  double screenWidth = 0;
  bool enLigne = true;
  List<String> _subMenuOptions = [
    'Entraînement Facile',
    'Entraînement Difficile'
  ];
  String _selectedSubMenu = "";
  String? pseudo;

  @override
  void initState() {
    super.initState();
    retrieveSession();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    // WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.paused) {
  //     // L'application est en cours de mise en pause (fermée)
  //     // Mettez enLigne à false ici
  //     setState(() {
  //       enLigne = false;
  //     });
  //     envoiHorsLigne(); // Appelez la fonction d'envoi lorsque l'application est en pause
  //   } else if (state == AppLifecycleState.resumed) {
  //     // L'application est en cours de reprise
  //     // Mettez enLigne à true ici
  //     setState(() {
  //       enLigne = true;
  //     });
  //     envoiHorsLigne(); // Appelez la fonction d'envoi lorsque l'application reprend
  //   }
  // }
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     setState(() {
  //       enLigne = true;
  //       envoiHorsLigne();
  //     });
  //   } else {
  //     setState(() {
  //       // enLigne = false;
  //       enLigne = true; //pr pvoir bosser en localhost
  //       envoiHorsLigne(); //met bien hors ligne mais seulement si l'appli est en arriere plan
  //     });
  //   }
  // }

  Future<void> retrieveSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedPseudo = prefs.getString('pseudo');
    setState(() {
      pseudo = storedPseudo;
    });
    // setState(() {
    //   enLigne = true;
    // });
    // envoiHorsLigne();
  }

  void envoiHorsLigne() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/statutLigne'),
        body: json.encode({
          'pseudo': pseudo,
          "enLigne": enLigne,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Vous pouvez ignorer la réponse du serveur ici si vous n'en avez pas besoin
      } else {
        print('Échec de la requête HTTP avec le code ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    // final double screenWidth = mediaQuery.size.width;
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 400) {
      screenWidth = 400;
    }
    final double screenHeight = mediaQuery.size.height;
    final double appBarHeight = AppBar().preferredSize.height;
    final double topPosition = mediaQuery.padding.top + appBarHeight;
    final double topForGame = mediaQuery.padding.top;
    final double bottomPosition = screenHeight;
    final double bottomForGame = screenHeight - screenHeight / 3;
    final double leftPosition = mediaQuery.padding.left;
    final double rightPosition = screenWidth;
    final double realScreenHeight = bottomForGame;

    return Scaffold(
      appBar: !_inGame
          ? AppBar(
              backgroundColor: Color.fromARGB(255, 101, 153, 220),
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: Icon(FontAwesomeIcons.bars),
                    onPressed: () {
                      Scaffold.of(context)
                          .openDrawer(); // Ouvrir le drawer lorsque le bouton est cliqué
                    },
                  );
                },
              ),
              title: Row(
                children: [
                  if (pseudo != null) Container(),
                  SizedBox(width: 8),
                  Text(
                    pseudo != null ? '$pseudo' : 'Non connecté',
                    style: TextStyle(
                      color: Color.fromRGBO(28, 28, 28, 1),
                    ),
                  ),
                ],
              ),
              // iconTheme: IconThemeData(
              //   color: Colors.white, // Couleur blanche pour l'icône
              //   size: 30,
              // ),
              actions: [
                if (pseudo != null)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentIndex = 6;
                          _selectedSubMenu = "";
                        });
                      },
                      icon: Icon(FontAwesomeIcons.rightFromBracket),
                      label: Text('Déconnexion'),
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                      ),
                    ),
                  ),
              ],
            )
          : null,
      drawer: buildDrawer(),
      body: Container(
        color: Colors.black,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth < 400 ? screenWidth : 400,
            ),
            child: _getCurrentScreen(
              screenWidth,
              screenHeight,
              topPosition,
              bottomPosition,
              leftPosition,
              rightPosition,
              realScreenHeight,
              topForGame,
              bottomForGame,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Menu'),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text(
              'Accueil',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              setState(() {
                _currentIndex = 0;
                _selectedSubMenu = ""; // Réinitialise le sous-menu sélectionné
              });
              Navigator.pop(context);
            },
          ),
          if (pseudo == null)
            ListTile(
              title: Text(
                'Inscription',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                setState(() {
                  _currentIndex = 4;
                  _selectedSubMenu =
                      ""; // Réinitialise le sous-menu sélectionné
                });
                Navigator.pop(context);
              },
            ),
          if (pseudo == null)
            ListTile(
              title: Text(
                'Connexion',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                setState(() {
                  _currentIndex = 5;
                  _selectedSubMenu =
                      ""; // Réinitialise le sous-menu sélectionné
                });
                Navigator.pop(context);
              },
            ),
          ExpansionTile(
            title: Text(
              'Solo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onExpansionChanged: (value) {
              setState(() {
                _selectedSubMenu = 'Solo';
                showSubMenu = value;
              });
            },
            initiallyExpanded: showSubMenu,
            children: [
              ListTile(
                title: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        Icons.circle,
                        size: 8,
                        color: Colors.black, // Couleur de la puce
                      ),
                    ),
                    Text(
                      'Solo mode Facile',
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _currentIndex = 1;
                    showSubMenu = false;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        Icons.circle,
                        size: 8,
                        color: Colors.black, // Couleur de la puce
                      ),
                    ),
                    Text(
                      'Solo mode Difficile',
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _currentIndex = 2;
                    showSubMenu = false;
                  });
                  Navigator.pop(context);
                },
              ),
              // ListTile(
              //   title: Row(
              //     children: [
              //       Padding(
              //         padding: const EdgeInsets.only(right: 8.0),
              //         child: Icon(
              //           Icons.circle,
              //           size: 8,
              //           color: Colors.black, // Couleur de la puce
              //         ),
              //       ),
              //       Text(
              //         'manette',
              //       ),
              //     ],
              //   ),
              //   onTap: () {
              //     setState(() {
              //       _currentIndex = 8;
              //       showSubMenu = false;
              //     });
              //     Navigator.pop(context);
              //   },
              // ),
            ],
          ),
          ListTile(
            title: Text(
              'Profil',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              setState(() {
                _currentIndex = 9;
                _selectedSubMenu = ""; // Réinitialise le sous-menu sélectionné
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(
              'Versus',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              setState(() {
                _currentIndex = 3;
                _selectedSubMenu = ""; // Réinitialise le sous-menu sélectionné
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 300.0),
                  child: Text(
                    "Amis", // Couleur de la puce
                  ),
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _currentIndex = 7;
                showSubMenu = false;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _getCurrentScreen(
    // MainScreenState mainScreenState,
    double screenWidth,
    double screenHeight,
    double topPosition,
    double bottomPosition,
    double leftPosition,
    double rightPosition,
    double realScreenHeight,
    double topForGame,
    double bottomForGame,

    // Ajoutez une référence à SocketIoManager
  ) {
    switch (_currentIndex) {
      case 0:
        return HomePage(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          topPosition: topPosition,
          bottomPosition: bottomPosition,
          leftPosition: leftPosition,
          rightPosition: rightPosition,
        );

      case 1:
        return PingPongScreen(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          topPosition: topPosition,
          bottomPosition: bottomPosition,
          leftPosition: leftPosition,
          rightPosition: rightPosition,
          realScreenHeight: realScreenHeight,
          bottomForGame: bottomForGame,
          pseudo: pseudo ?? '',
        );
      case 2:
        return EntrHard(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          topPosition: topPosition,
          bottomPosition: bottomPosition,
          leftPosition: leftPosition,
          rightPosition: rightPosition,
          realScreenHeight: realScreenHeight,
          bottomForGame: bottomForGame,
          pseudo: pseudo ?? '',
        );
      case 3:
        return Versus(
          leftPosition: leftPosition,
          rightPosition: rightPosition,
          topForGame: topForGame,
          bottomForGame: bottomForGame,
          onGameStatusChanged: (isGameInProgress) {
            setState(() {
              _inGame = isGameInProgress;
            });
          },
          pseudo: pseudo ?? '',
        );

      case 4:
        return PseudoForm();
      case 5:
        return ConnexionScreen();
      case 6:
        return DeconnexionScreen();
      case 7:
        return Amis(
          pseudo: pseudo ?? '',
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          // mainScreenState: this,
        );
      // case 8:
      //   return MyGame();
      case 9:
        return Profil(
          pseudo: pseudo ?? '',
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        );
      default:
        return HomePage(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          topPosition: topPosition,
          bottomPosition: bottomPosition,
          leftPosition: leftPosition,
          rightPosition: rightPosition,
        );
    }
  }
}
