import 'package:flutter/material.dart';
import 'package:fuck_circle/utils/socket.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final double topPosition;
  final double bottomPosition;
  final double leftPosition;
  final double rightPosition;

  HomePage({
    required this.screenWidth,
    required this.screenHeight,
    required this.topPosition,
    required this.bottomPosition,
    required this.leftPosition,
    required this.rightPosition,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> highestScores = {
    'entrFacile': {'pseudo': 'N/A', 'score': 'N/A'},
    'entrDifficile': {'pseudo': 'N/A', 'score': 'N/A'},
  };

  SocketIoManager socketIoManager = SocketIoManager();
  @override
  void initState() {
    super.initState();

    bestScores();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.1),
        image: DecorationImage(
          image: AssetImage(
              'assets/image/fond.jpg'), // Chemin vers l'image dans assets
          fit: BoxFit.cover, // Ajustez l'image pour remplir le conteneur
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centrer verticalement
          children: [
            SizedBox(height: 40), // Espace supplémentaire en haut
            Text(
              'Fuck-Circles', // Titre "APPLIGUIB" en bleu
              style: TextStyle(
                  fontSize: 30,
                  color: Color.fromARGB(255, 34, 146, 238),
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Meilleurs scores:',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
            ),
            SizedBox(
                height:
                    10), // Espace supplémentaire entre le titre et le texte des scores
            Text(
              'Mode facile: ${highestScores['entrFacile']['pseudo']} - ${highestScores['entrFacile']['score']}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(
                height:
                    10), // Espace supplémentaire entre les deux lignes de scores
            Text(
              'Mode difficile: ${highestScores['entrDifficile']['pseudo']} - ${highestScores['entrDifficile']['score']}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    ));
  }

  // void updateHighestScores() async {
  //   if (mounted) {
  //     final getScore = {
  //       'pseudo': "all",
  //       'mode': 'all',
  //     };

  //     socketIoManager.sendGetHighestScores(getScore);

  //     socketIoManager.listenForHighestScores((scores) {
  //       if (mounted) {
  //         setState(() {
  //           // Met à jour les meilleurs scores et pseudos
  //           highestScores['entrFacile']['pseudo'] =
  //               scores['entrFacile']?.keys.first ?? 'N/A';
  //           highestScores['entrFacile']['score'] =
  //               scores['entrFacile']?.values.first?.toString() ?? 'N/A';
  //           highestScores['entrDifficile']['pseudo'] =
  //               scores['entrDifficile']?.keys.first ?? 'N/A';
  //           highestScores['entrDifficile']['score'] =
  //               scores['entrDifficile']?.values.first?.toString() ?? 'N/A';
  //         });
  //       }
  //     });
  //   }
  // }

  Future<void> bestScores() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/bestScores'),
        // Uri.parse('http://192.168.164.141:8080/bestScores'),
        body: json.encode({
          'pseudo': "all",
          'mode': "all",
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final scores = data['scores'];

        // Utilisez les scores récupérés comme vous le souhaitez

        setState(() {
          //           // Met à jour les meilleurs scores et pseudos
          highestScores['entrFacile']['pseudo'] =
              scores['entrFacile']?.keys.first ?? 'N/A';
          highestScores['entrFacile']['score'] =
              scores['entrFacile']?.values.first?.toString() ?? 'N/A';
          highestScores['entrDifficile']['pseudo'] =
              scores['entrDifficile']?.keys.first ?? 'N/A';
          highestScores['entrDifficile']['score'] =
              scores['entrDifficile']?.values.first?.toString() ?? 'N/A';
        });
      } else {
        print('Échec de la requête HTTP avec le code ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP : $e');
    }
  }
}
