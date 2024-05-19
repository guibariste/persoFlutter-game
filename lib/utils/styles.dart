import 'package:flutter/material.dart';

final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
  onPrimary: Colors.black87,
  primary: Color.fromARGB(255, 139, 168, 197),
  minimumSize: Size(88, 36),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(50), // Bords bien ronds
    side: BorderSide(
        color:
            const Color.fromARGB(255, 13, 13, 13)), // Bordure autour du bouton
  ),
  textStyle: TextStyle(
    color: Colors.black, // Couleur du texte du bouton
    fontWeight: FontWeight.bold, // Style de la police du texte
    fontSize: 16, // Taille du texte
  ),
);

final InputDecorationTheme myInputDecorationTheme = InputDecorationTheme(
  border: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey),
    borderRadius: BorderRadius.circular(10),
  ),
  // contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  contentPadding: EdgeInsets.only(left: 10, right: 0),
  labelStyle: TextStyle(color: Colors.black),
  hintStyle: TextStyle(color: Colors.grey),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blue),
    borderRadius: BorderRadius.circular(10),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey),
    borderRadius: BorderRadius.circular(10),
  ),
);
