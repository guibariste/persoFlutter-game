import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<String> getDatabasePath() async {
  sqfliteFfiInit();

  var databaseFactory = databaseFactoryFfi;
  var directory = await getApplicationDocumentsDirectory();
  var databasePath = '${directory.path}/dbFuckCircle.db';

  return databasePath;
}

Future<bool> checkDatabaseExists() async {
  String databasePath = await getDatabasePath();
  return File(databasePath).exists();
}

// Future<List<String>> getAllUsernames() async {
//   var db = await databaseFactory.openDatabase(await getDatabasePath());
//   final List<Map<String, dynamic>> maps = await db.query('Utilisateur');
//   await db.close();

//   // Récupérer tous les pseudos des utilisateurs
//   List<String> usernames = maps.map((map) => map['Pseudo'] as String).toList();
//   return usernames;
// }
Future<void> insertUtilisateur(String pseudo, String mdp) async {
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
          Mdp TEXT
      )
    ''');
  }

  await db.insert('Utilisateur', <String, Object?>{
    'Pseudo': pseudo,
    'Mdp': mdp,
  });

  var result = await db.query('Utilisateur');
  await db.close();
}
