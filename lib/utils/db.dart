import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:flutter/material.dart';
import 'package:fuck_circle/main.dart';

class DatabaseHelper {
  // Déclaration de la variable globale databaseFactory
  static DatabaseFactory databaseFactory = databaseFactoryFfi;

  // Initialisation de sqflite ffi
  static void initialize() {
    sqfliteFfiInit();
  }

  // Récupère le chemin de la base de données
  static Future<String> getDatabasePath() async {
    var directory = await getApplicationDocumentsDirectory();
    var databasePath = '${directory.path}/dbFuckCircle.db';
    return databasePath;
  }

  // Vérifie si la base de données existe
  static Future<bool> checkDatabaseExists() async {
    String databasePath = await getDatabasePath();
    return File(databasePath).exists();
  }

  // Crée la table 'Utilisateur' si elle n'existe pas
  static Future<void> createTableIfNotExists() async {
    var db = await databaseFactory.openDatabase(await getDatabasePath());

    var tables = await db.query(
      "sqlite_master",
      where: "type = 'table' AND name = 'Utilisateur'",
    );

    if (tables.isEmpty) {
      await db.execute('''
        CREATE TABLE Utilisateur (
            id INTEGER PRIMARY KEY,
            Pseudo TEXT,
            Mdp TEXT
        )
      ''');
    }

    await db.close();
  }

  static Future<void> insertUtilisateur(String pseudo, String mdp, String age,
      String pays, String code, String image) async {
    // sqfliteFfiInit();

    // var databaseFactory = databaseFactoryFfi;
    // var directory = await getApplicationDocumentsDirectory();
    // var databasePath = '${directory.path}/database.db';

    // Créer le fichier de base de données

    await File(await getDatabasePath()).create(recursive: true);

    var db = await databaseFactory.openDatabase(await getDatabasePath());

    var tables = await db.query(
      "sqlite_master",
      where: "type = 'table' AND name = 'Utilisateur'",
    );

    if (tables.isEmpty) {
      await db.execute('''
      CREATE TABLE Utilisateur (
          id INTEGER PRIMARY KEY,
          Pseudo TEXT,
          Mdp TEXT,
          Age TEXT,
          Pays TEXT,
          CodeCountry TEXT,
          Image TEXT
      )
    ''');
    }

    await db.insert('Utilisateur', <String, Object?>{
      'Pseudo': pseudo,
      'Mdp': mdp,
      'Age': age,
      'Pays': pays,
      'CodeCountry': code,
      'Image': image,
    });

    // var result = await db.query('Utilisateur');
    await db.close();
  }

  static Future<void> insertScore(
      String? pseudo, int score, String mode) async {
    await File(await getDatabasePath()).create(recursive: true);

    var db = await databaseFactory.openDatabase(await getDatabasePath());

    var tables = await db.query(
      "sqlite_master",
      where: "type = 'table' AND name = 'Score'",
    );

    if (tables.isEmpty) {
      await db.execute('''
      CREATE TABLE Score (
          id INTEGER PRIMARY KEY,
          Pseudo TEXT,
          Score  INTEGER,
          Mode   TEXT
      )
    ''');
    }

    await db.insert('Score',
        <String, Object?>{'Pseudo': pseudo, 'Score': score, 'Mode': mode});

    // var result = await db.query('Score');
    await db.close();
  }

  static Future<bool> validateConnexion(String pseudo, String mdp) async {
    await File(await getDatabasePath()).create(recursive: true);

    var db = await databaseFactory.openDatabase(await getDatabasePath());

    var result = await db.query(
      'Utilisateur',
      where: 'Pseudo = ? AND Mdp = ?',
      whereArgs: [pseudo, mdp],
      limit: 1,
    );

    await db.close();

    return result.isNotEmpty;

    // return false; // Retourner une valeur par défaut en cas d'erreur
  }

  // Récupère tous les pseudos des utilisateurs dans la table 'Utilisateur'
  static Future<List<String>> getAllUsernames() async {
    var db = await databaseFactory.openDatabase(await getDatabasePath());
    final List<Map<String, dynamic>> maps = await db.query('Utilisateur');
    await db.close();

    // Récupérer tous les pseudos des utilisateurs
    List<String> usernames =
        maps.map((map) => map['Pseudo'] as String).toList();
    return usernames;
  }

  static Future<List<String>> getProfil(String pseudo) async {
    var db = await databaseFactory.openDatabase(await getDatabasePath());

    var profils =
        await db.query('Utilisateur', where: 'Pseudo = ?', whereArgs: [pseudo]);
    List<String> profil = [];
    profils.forEach((friend) {
      profil.add(friend['Pseudo'] as String);
      profil.add(friend['Age'] as String); // Ajouter l'âge
      profil.add(friend['Pays'] as String);
      profil.add(friend['CodeCountry'] as String);
      profil
          .add(friend['Image'] as String); // Ajouter l'image encodée en base64
    });
    return profil;
  }

  static Future<int> getHighestScore(String pseudo, String mode) async {
    var db = await databaseFactory.openDatabase(await getDatabasePath());

    // Requête SQL pour récupérer le score le plus élevé associé au pseudo
    final result = await db.rawQuery(
      'SELECT MAX(Score) AS highest_score FROM Score WHERE Pseudo = ? AND Mode = ?',
      [pseudo, mode],
    );

    // Vérifie si le résultat n'est pas vide et retourne le score le plus élevé
    if (result.isNotEmpty) {
      int? highestScore = result.first['highest_score'] as int?;
      return highestScore ?? 0;
    }

    return 0; // Si aucun score n'a été trouvé, retourne 0
  }

  static Future<List<String>> getFriends(String pseudo) async {
    var db = await databaseFactory.openDatabase(await getDatabasePath());
    var friends =
        await db.query('Amis', where: 'User = ?', whereArgs: [pseudo]);
    List<String> amis = [];
    friends.forEach((friend) {
      amis.add(friend['Ami'] as String);
    });
    return amis;
  }
}
