import 'dart:io';

import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:fuck_circle/main.dart';

import 'package:image_picker/image_picker.dart';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class PseudoForm extends StatefulWidget {
  @override
  _PseudoFormState createState() => _PseudoFormState();
}

class _PseudoFormState extends State<PseudoForm> {
  @override
  void initState() {
    super.initState();
  }

  MediaType? mediaTypeData;

  // ...

  void _getImageFromSource(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        mediaTypeData = MediaType.parse(lookupMimeType(_imageFile!.path)!);
      });
    }
  }

  File? _imageFile; // Variable pour stocker l'image

  bool inscrit = false;

  // String? _base64Image;
  String? codePays;
  String? nomPays;
  TextEditingController _pseudoController = TextEditingController();
  TextEditingController _mdpController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  String msgErreur = "";
  final _formKey = GlobalKey<FormState>(); // Clé globale pour le formulaire
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey, // Utilisation de la clé pour le formulaire
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
                    return null; // Validation réussie
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
                  obscureText: true, // Masquer le texte du mot de passe
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le champ Mot de passe est requis';
                    }
                    if (value.length < 6) {
                      return 'Le Mot de passe doit contenir au moins 6 caractères';
                    }
                    if (!containsNumber(value)) {
                      return 'Le Mot de passe doit contenir au moins un chiffre';
                    }
                    return null; // Validation réussie
                  },
                ),
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.6,
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: 'Age(optionnel)',
                  ),
                ),
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.6,
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: CountryListPick(
                  appBar: AppBar(
                    backgroundColor: Colors.blue,
                    title: Text('Choisir un pays'),
                  ),
                  // Si vous voulez afficher un drapeau en face de chaque nom de pays, définissez "flagBuilder"
                  // Sinon, définissez "dropdownIcon" pour afficher une icône de liste déroulante.
                  // dropdownIcon: Icon(Icons.arrow_drop_down),
                  onChanged: (CountryCode? code) {
                    setState(() {
                      codePays = code!.code;
                      nomPays = code.name;

                      // Faites quelque chose avec le code ISO du pays sélectionné (code!.code)
                      // Vous pouvez également obtenir le nom du pays sélectionné avec code!.name
                    });
                  },
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Montre une boîte de dialogue pour permettre à l'utilisateur de choisir entre la galerie et l'appareil photo
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Choisissez une option'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _getImageFromSource(ImageSource.gallery);
                          },
                          child: Text('Galerie'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _getImageFromSource(ImageSource.camera);
                          },
                          child: Text('Appareil photo'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Sélectionner une photo de profil'),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    String pseudo = _pseudoController.text;
                    // String image = _imageFile != null
                    //     ? base64Encode(_imageFile!.readAsBytesSync())
                    //     : '';
                    String mdp = _mdpController.text;
                    String age = _ageController.text;
                    String pays = nomPays!;
                    String code = codePays!;

                    if (_imageFile != null) {
                      await fetchInscription(pseudo, _imageFile, mdp, age, pays,
                          code); // Passer _imageFile ici
                    } else {
                      await fetchInscription(pseudo, null, mdp, age, pays,
                          code); // Passer null pour imageFile
                    }

                    if (inscrit) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Inscription réussie'),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Pseudo: $pseudo'),
                                if (_imageFile != null) ...[
                                  SizedBox(height: 16),
                                  Image.file(
                                    _imageFile!,
                                    width: 100,
                                    height: 100,
                                  ),
                                ],
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  final mainScreenState =
                                      MainScreenState(); // Créez une instance de MainScreenState
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return MainScreen();
                                  }));
                                },
                                child: Text('Fermer'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } else {
                    print(msgErreur);
                  }
                },
                child: Text('Valider'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> fetchInscription(
  //   String pseudo,
  //   File imageFile,
  //   String mdp,
  //   String age,
  //   String pays,
  //   String code,
  // ) async {
  //   try {
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse('http://localhost:8080/inscription'),
  //     );

  //     // Ajoutez les données d'inscription en tant que champs dans la requête
  //     request.fields['pseudo'] = pseudo;
  //     request.fields['mdp'] = mdp;
  //     request.fields['age'] = age;
  //     request.fields['pays'] = pays;
  //     request.fields['code'] = code;

  //     // Ajoutez l'image en tant que fichier multipart si elle est fournie
  //     if (imageFile != null) {
  //       final file = await http.MultipartFile.fromPath(
  //         'image',
  //         imageFile.path,
  //         contentType: mediaTypeData,
  //       );
  //       request.files.add(file);
  //     }

  //     final response = await request.send();

  //     // Traitement de la réponse...
  //   } catch (e) {
  //     print('Erreur lors de la requête HTTP : $e');
  //   }
  // }
  Future<void> fetchInscription(
    String pseudo,
    File? imageFile,
    String mdp,
    String age,
    String pays,
    String code,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        // Uri.parse('http://192.168.164.141:8080/inscription'),
        Uri.parse('http://localhost:8080/inscription'),
      );

      // Ajoutez les données d'inscription en tant que champs dans la requête
      request.fields['pseudo'] = pseudo;
      request.fields['mdp'] = mdp;
      request.fields['age'] = age;
      request.fields['pays'] = pays;
      request.fields['code'] = code;

      // Ajoutez l'image en tant que fichier multipart si elle est fournie
      if (imageFile != null) {
        final file = await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: mediaTypeData,
        );
        request.files.add(file);
      }

      final response = await request.send();

      // Attendre la réponse et la lire sous forme de chaîne
      final responseData = await response.stream.bytesToString();

      // Analysez la réponse JSON
      final jsonResponse = json.decode(responseData);

      // Récupérez les valeurs "inscrit" et "message" du JSON
      // final bool inscrit = jsonResponse['inscrit'];
      // final String message = msgErreur
      setState(() {
        inscrit = jsonResponse['inscrit'];
        msgErreur = jsonResponse['message'];
      });

      // Vous pouvez également renvoyer ces valeurs ou effectuer d'autres actions en fonction de votre logique d'application
    } catch (e) {
      print('Erreur lors de la requête HTTP : $e');
    }
  }

  // Future<void> fetchInscription(
  //   String pseudo,
  //   File imageFile, // Modifiez le type de paramètre ici
  //   String mdp,
  //   String age,
  //   String pays,
  //   String code,
  // ) async {
  //   try {
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse('http://localhost:8080/inscription'),
  //     );

  //     // ...

  //     // Ajoutez l'image en tant que fichier multipart si elle est fournie
  //     if (imageFile != null) {
  //       final file = await http.MultipartFile.fromPath(
  //         'image',
  //         imageFile.path,
  //         contentType: mediaTypeData,
  //       );
  //       request.files.add(file);
  //     }

  //     final response = await request.send();

  //     // ...
  //   } catch (e) {
  //     print('Erreur lors de la requête HTTP : $e');
  //   }
  // }

  // ...
}

// Future<void> fetchInscription(
//   String pseudo,
//   String image,
//   String mdp,
//   String age,
//   String pays,
//   String code,
// ) async {
//   try {
//     final response = await http.post(
//       Uri.parse('http://localhost:8080/inscription'),
//       body: json.encode({
//         'pseudo': pseudo,
//         'image': image,
//         'mdp': mdp,
//         'age': age,
//         'pays': pays,
//         'code': code,
//       }),
//       headers: {
//         'Content-Type': 'application/json',
//       },
//     );

//     if (response.statusCode == 200) {
//       final jsonData = json.decode(response.body);
//       setState(() {
//         inscrit = jsonData['inscrit'];
//         msgErreur = jsonData['message'];
//       });
//     } else {
//       print('Échec de la requête HTTP avec le code ${response.statusCode}');
//     }
//   } catch (e) {
//     print('Erreur lors de la requête HTTP : $e');
//   }
// }

// void _getImageFromSource(ImageSource source) async {
//   final pickedFile = await ImagePicker().getImage(source: source);
//   if (pickedFile != null) {
//     setState(() {
//       _imageFile = File(pickedFile.path);
//     });
//   }
// }

bool containsNumber(String value) {
  return RegExp(r'\d').hasMatch(value);
}
