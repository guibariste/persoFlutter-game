import 'package:flutter/material.dart';
import 'dart:math';
import 'package:country_flags/country_flags.dart';
import 'package:fuck_circle/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fuck_circle/utils/image.dart';

class Profil extends StatefulWidget {
  final String pseudo;
  final double screenWidth;
  final double screenHeight;

  Profil({
    required this.pseudo,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  _ProfilWidgetState createState() => _ProfilWidgetState();
}

class _ProfilWidgetState extends State<Profil> {
  List<String> _profilData = [];
  bool _isLoggedIn = false;
  int bestEntrFacile = 0;
  int bestEntrDifficile = 0;
  int victoires = 0;
  int defaites = 0;
  int nuls = 0;
  int nbreParties = 0;
  double ratio = 0;
  String ratioFormatted = "";

  var image;
  dynamic blob;
  // late Uint8List image;
  @override
  void initState() {
    super.initState();

    _checkLoginStatus();
    getProfil(widget.pseudo);
    getScoresProfil(widget.pseudo);
    // _loadProfilData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _checkLoginStatus() {
    // Vérifiez si le pseudo est vide (non connecté)
    if (widget.pseudo.isEmpty) {
      _isLoggedIn = false;
    } else {
      _isLoggedIn = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoggedIn
          ? _buildProfilContent()
          : _buildLoginAlert(), // Affiche le profil ou l'alerte en fonction de l'état de connexion
    );
  }

  Widget _buildProfilContent() {
    if (_profilData.length > 4) {
      blob = _profilData[4];
    } else {}

    try {
      if (blob != null && blob.isNotEmpty) {
        image = Base64Codec().decode(blob);
      } else {
        image = null;
      }
    } catch (e) {
      print("Erreur lors du décodage base64 : $e");
    }
    ratio = victoires / (victoires + defaites);
    ratio = max(
        0, min(1, ratio)); // Assurez-vous que le ratio est compris entre 0 et 1
    String ratioFormatted = ratio.toStringAsFixed(2);

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (image != null) // Vérifiez si l'image n'est pas nulle
                  CircleImageWidget(
                    image: image,
                    radius: 40,
                  ),
                if (image ==
                    null) // Si l'image est nulle, affichez une icône ou du texte par défaut
                  Icon(Icons.person_outline, size: 80), // V

                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ' ${_profilData.isNotEmpty ? _profilData[0] : ''}',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Âge: ${_profilData.isNotEmpty ? _profilData[1] : ''}',
                      style: TextStyle(fontSize: 16),
                    ),
                    if (_profilData.length >= 4) SizedBox(height: 10),
                    Row(
                      children: [
                        CountryFlags.flag(
                          _profilData.length >= 4 ? _profilData[3] : '',
                          width: 64,
                          height: 48,
                          borderRadius: 5,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Pays: ${_profilData.isNotEmpty && _profilData.length >= 3 ? _profilData[2] : ''}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Meilleurs scores :', // Ajoutez ici votre titre de liste
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Solo Facile : $bestEntrFacile', // Ajoutez ici votre titre de liste
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Solo Difficile : $bestEntrDifficile', // Ajoutez ici votre titre de liste
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Multijoueur : ', // Ajoutez ici votre titre de liste
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Nbres parties : $nbreParties', // Ajoutez ici votre titre de liste
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Victoires : $victoires', // Ajoutez ici votre titre de liste
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Défaites : $defaites', // Ajoutez ici votre titre de liste
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Nuls : $nuls', // Ajoutez ici votre titre de liste
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Ratio : $ratioFormatted', // Ajoutez ici votre titre de liste
              style: TextStyle(fontSize: 20),
            ),
          ),
          // Expanded(
          //   child: ListView.builder(
          //     itemCount: 10, // Remplacez par le nombre de scores à afficher
          //     itemBuilder: (context, index) {
          //       return ListTile(
          //         title: Text(
          //           'Score ${index + 1}: 1000', // Remplacez par votre score et son format
          //           style: TextStyle(fontSize: 16),
          //         ),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildLoginAlert() {
    return AlertDialog(
      title: Text('Alerte'),
      content: Text('Vous devez vous connecter pour accéder au profil.'),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return MainScreen();
            }));
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => MainScreen(),
            //   ),
            // );
          },
          child: Text('Retour a l\'accueil'),
        ),
      ],
    );
  }

  Future<void> getProfil(pseudo) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/getProfil'),
        // Uri.parse('http://192.168.164.141:8080/getProfil'),
        body: json.encode({
          'pseudo': pseudo,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final profilData = jsonData['profilData'] as List<dynamic>?;

        if (profilData != null) {
          final profilDataStrings =
              profilData.map((item) => item?.toString() ?? '').toList();
          setState(() {
            _profilData = profilDataStrings;
          });

          if (profilData.length > 4 && profilData[4] != null) {
            final blob = profilData[4] as String;
            try {
              image = Base64Codec().decode(blob);
            } catch (e) {
              print("Erreur lors du décodage base64 : $e");
              // Gérer le cas où les données ne sont pas correctement encodées en base64
            }
          } else {
            blob = null;
            image = null;
          }
        }
      } else {
        print('Échec de la requête HTTP avec le code ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP : $e');
    }
  }

  Future<void> getScoresProfil(pseudo) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/getScoresProfil'),
        // Uri.parse('http://192.168.164.141:8080/getScoresProfil'),
        body: json.encode({
          'pseudo': pseudo,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        final scores = jsonData['scores'];
        // print(scores['victoires']);
        // print(scores['defaites']);
        // print(scores['nuls']);
        // print(scores['parties']);
        print(scores['entrFacile']);
        setState(() {
          bestEntrFacile = scores['entrFacile'];
          bestEntrDifficile = scores['entrDifficile'];
          victoires = scores['victoires'];
          defaites = scores['defaites'];
          nuls = scores['nuls'];
          nbreParties = scores['parties'];
        });
      } else {
        print('Échec de la requête HTTP avec le code ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP : $e');
    }
  }
}
