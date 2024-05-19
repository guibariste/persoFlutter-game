import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fuck_circle/main.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

class DeconnexionScreen extends StatelessWidget {
  final Function?
      onLogout; // Nouvelle propriété pour la fonction de déconnexion

  DeconnexionScreen({this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Déconnexion'),
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                logout(context);
              },
              child: Text('OK'),
            ),
            SizedBox(height: 8.0),
            TextButton(
              onPressed: () {
                final mainScreenState =
                    MainScreenState(); // Créez une instance de MainScreenState
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return MainScreen();
                }));
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => MainScreen(),
                //   ),
                // );
              },
              child: Text('Annuler'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('pseudo'); // Suppression de la clé 'pseudo'
    onLogout?.call();
    // Navigator.pop(context, true); // Retour à l'écran précédent (accueil)

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MainScreen();
    }));
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => MainScreen(),
    //   ),
    // );
  }
}
