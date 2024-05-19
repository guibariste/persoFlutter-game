import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:fuck_circle/main.dart';

import 'package:path_provider/path_provider.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

class ConnexionScreen extends StatefulWidget {
  @override
  _ConnexionScreenState createState() => _ConnexionScreenState();
}

class SharedPreferencesUtil {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> getSharedPreferences() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    return _prefs!;
  }
}

class _ConnexionScreenState extends State<ConnexionScreen> {
  bool isConnected = false;
  bool userExists = false;
  // late IO.Socket socket;
  //---------android-----------------------
  // sqfliteFfiInit() {}
  // var databaseFactory = databaseFactoryFfi;
  //-------------------------------------

  // }
  @override
  void initState() {
    super.initState();
    // connectToSocket();
  }

  @override
  void dispose() {
    super.dispose();
    // socket.dispose();
  }

  TextEditingController _pseudoController = TextEditingController();
  TextEditingController _mdpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // @override
  // void dispose() {
  //   super.dispose();
  //   socketIoManager.closeSocket();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Formulaire de connexion'),
      // ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            FractionallySizedBox(
              widthFactor: 0.6,
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _pseudoController,
                  decoration: InputDecoration(
                    labelText: 'Pseudo',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le champ Pseudo est requis';
                    }
                    return null;
                  },
                ),
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.6,
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _mdpController,
                  decoration: InputDecoration(
                    labelText: 'Mdp',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le champ Mot de passe est requis';
                    }
                    return null;
                  },
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // socketStop();
                if (_formKey.currentState!.validate()) {
                  String pseudo = _pseudoController.text;
                  String mdp = _mdpController.text;
                  // String encryptedMdp =
                  //     sha256.convert(utf8.encode(mdp)).toString();
                  await fetchConnexion(pseudo, mdp);
                  if (isConnected) {
                    saveSession(pseudo);

                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return MainScreen();
                    }));
                  } else {
                    if (userExists) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Erreur de connexion'),
                            content: Text('Pseudo ou mot de passe incorrect'),
                            actions: [
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // Le pseudo n'existe pas, vous pouvez afficher un message d'erreur différent ici

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Erreur de connexion'),
                            content: Text('Pseudo non trouvé'),
                            actions: [
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                }
              },
              child: Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }

  // void connectToSocket() {
  //   // socket = IO.io('http://51.103.26.79:8080', <String, dynamic>{
  //   //   'transports': ['websocket'],
  //   // });
  //   socket = IO.io('http://localhost:8080', <String, dynamic>{
  //     'transports': ['websocket'],
  //   });

  //   socket.on('message', (message) {
  //     print(message);
  //   });
  // }

  // void socketStop() {
  //   socket.emit('essai', "stop");
  // }

  Future<void> fetchConnexion(String pseudo, String mdp) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/connexion'),
        // Uri.parse('http://192.168.164.141:8080/connexion'),
        body: json.encode({
          'pseudo': pseudo,
          'mdp': mdp,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print(jsonData['connecte']);
        setState(() {
          isConnected = jsonData['connecte'];
          userExists = jsonData['userExists'];
        });
      } else {
        print('Échec de la requête HTTP avec le code ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP : $e');
    }
  }

  Future<void> saveSession(String pseudo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('pseudo', pseudo);
  }
}
