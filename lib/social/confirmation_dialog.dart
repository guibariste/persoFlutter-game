import 'package:flutter/material.dart';

// import 'package:fuck_circle/utils/dbAndroid.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
// import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class ConfirmationDialog extends StatelessWidget {
  final String username;
  final String pseudo;
  //  sqfliteFfiInit();

  // var databaseFactory = databaseFactoryFfi;
  ConfirmationDialog({required this.username, required this.pseudo});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ajouter un ami'),
      content: Text('Voulez-vous ajouter $username comme ami ?'),
      actions: [
        TextButton(
          child: Text('Annuler'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Ajouter'),
          onPressed: () async {
            // addFriend(username);
            demandeAmi(pseudo, username);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void demandeAmi(pseudo, pseudoAmi) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/demandeAmi'),
        // Uri.parse('http://192.168.164.141:8080/demandeAmi'),

        body: json.encode({'pseudoDemande': pseudoAmi, "pseudo": pseudo}),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data['demande']);
        print(data['message']);
      } else {
        print('Échec de la requête HTTP avec le code ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP : $e');
    }
  }
}
