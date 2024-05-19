import 'package:flutter/material.dart';
import 'package:fuck_circle/main.dart';
import 'dart:convert';
import 'confirmation_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:fuck_circle/social/profil.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//revoir la logique pr ajouter ami on doit pas pouvoir ajouter une personne qui nexiste pas
//on peut inserer en double ds la db des demandes
//pr plus tard fonction pr voir les personnes bloques et pouvoir les debloquer

class Amis extends StatefulWidget {
  final String pseudo;
  final double screenWidth;
  final double screenHeight;

  Amis({
    required this.pseudo,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  AmisState createState() => AmisState();
}

class AmisState extends State<Amis> {
  TextEditingController _searchController = TextEditingController();
  List<String> allUsers = [];
  // List<String> amis = [];
  List<Map<String, dynamic>> _amis = [];
  List<String> demandesAmis = [];
  bool isSearching = false;
  String selectedUser = '';
  bool affAmis = true;
  bool affdemandes = false;
  bool acceptDemandeAmi = false;
  final MainScreenState mainscreen = MainScreenState();
  bool showProfile = false;
  bool boutonPrecedent = false;
  bool bloque = false;

  @override
  void initState() {
    super.initState();
    getFriends(widget.pseudo);
    getDemandeAmis(widget.pseudo);
  }

  List<String> filteredUsers() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
      });
      return [];
    }
    return allUsers
        .where((user) => user.toLowerCase().contains(query))
        .toList();
  }

// ...

  @override
  Widget build(BuildContext context) {
    Widget? content;
    if (showProfile) {
      setState(() {
        boutonPrecedent = true;
      });

      content = Profil(
        pseudo: selectedUser, // Ou utilisez les données appropriées
        screenWidth: widget.screenWidth,
        screenHeight: widget.screenHeight,
      );
    }
    if (!isSearching) {
      // Mode "Afficher demandes"
      if (affAmis) {
        content = Column(
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  affAmis = false;
                  affdemandes = true;
                  showProfile = false;
                });
              },
              child: Text('Afficher demandes'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _amis.length,
                itemBuilder: (BuildContext context, int index) {
                  String ami = _amis[index]['pseudo'];
                  String enLigne = _amis[index]['enLigne'];
                  return ListTile(
                    title: Text(ami),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showProfile = true;
                              affAmis = false;
                              affdemandes = false;
                              selectedUser = ami;
                            });
                          },
                          child: Text('Profil'),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              bloque = true;
                            });
                            bloquerAmis(ami);
                            // mainscreen.navigateToProfilPage(amis[index]);
                          },
                          child: Text('Bloquer'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      } else if (affdemandes) {
        content = Column(
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  affAmis = true;
                  affdemandes = false;
                  showProfile = false;
                });
              },
              child: Text('Afficher amis'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: demandesAmis.length,
                itemBuilder: (BuildContext context, int index) {
                  final demande = demandesAmis[index];
                  return ListTile(
                    title: Text('$demande vous a demande en ami:'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              acceptDemandeAmi = true;
                            });
                            acceptDemandeAmis(demandesAmis[index]);
                          },
                          child: Text('accepter'),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              acceptDemandeAmi = false;
                            });
                            acceptDemandeAmis(demandesAmis[index]);
                          },
                          child: Text('refuser'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }
    } else {
      // Mode de recherche
      content = ListView(
        children: filteredUsers().map((user) {
          return GestureDetector(
            onTap: () {
              if (_searchController.text.isEmpty) isSearching = false;
              setState(() {
                _searchController.text = user;
                selectedUser = user;
              });
            },
            child: ListTile(
              title: Text(user),
            ),
          );
        }).toList(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (boutonPrecedent)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    affAmis = true;
                    affdemandes = false;
                    showProfile = false;
                    boutonPrecedent = false;
                  });
                },
                child: Text('precedent'),
              ),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher des amis',
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (query) {
                  if (query.isEmpty) {
                    setState(() {
                      isSearching = false;
                    });
                  } else {
                    setState(() {
                      isSearching = true;
                    });
                  }
                  getAllUsers(widget.pseudo);
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Récupérez le texte de _searchController
                String searchText = _searchController.text;

                // Vérifiez si le texte correspond à l'un des utilisateurs
                if (doesUserExist(searchText)) {
                  _showConfirmationDialog(searchText);
                } else {
                  // L'utilisateur n'existe pas
                  print("Cet utilisateur n'existe pas");
                }
              },
              child: Text('Valider'),
            ),

            // ElevatedButton(
            //   onPressed: () {
            //     _showConfirmationDialog(_searchController.text);
            //   },
            //   child: Text('Valider'),
            // ),
          ],
        ),
      ),
      body: content,
    );
  }

  void _showConfirmationDialog(String username) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(pseudo: widget.pseudo, username: username);
      },
    );
  }

  bool doesUserExist(String username) {
    // Supposons que vous ayez une liste d'utilisateurs obtenue à partir de getAllUsers

    // Vérifiez si le nom d'utilisateur donné existe dans la liste des utilisateurs
    return allUsers.contains(username);
  }

  void getAllUsers(pseudo) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/getAllUsers'),
        // Uri.parse('http://192.168.164.141:8080/getAllUsers'),
        body: json.encode({
          'excludedPseudo': pseudo,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<String> users = [];
        final data = json.decode(response.body);
        for (var userData in data['username']) {
          users.add(userData);
        }

        setState(() {
          allUsers = users;
        });
      } else {
        print('Échec de la requête HTTP avec le code ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP : $e');
    }
  }

  void getFriends(pseudo) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/getAmis'),
        // Uri.parse('http://192.168.164.141:8080/getAmis'),
        body: json.encode({
          'pseudo': pseudo,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        for (var ami in data['amis']) {
          print('Ami: ${ami['pseudo']}, En ligne: ${ami['enLigne']}');
        }

        setState(() {
          _amis = List<Map<String, dynamic>>.from(data['amis']);
        });
      } else {
        print('Échec de la requête HTTP avec le code ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP : $e');
    }
  }

  void getDemandeAmis(pseudo) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/getDemandeAmis'),
        // Uri.parse('http://192.168.164.141:8080/getDemandeAmis'),
        body: json.encode({
          'pseudo': pseudo,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          demandesAmis = List<String>.from(data['demandeAmis']);
        });
      } else {
        print('Échec de la requête HTTP avec le code ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP : $e');
    }
  }

  void acceptDemandeAmis(pseudoDemandeur) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/acceptDemandeAmis'),
        // Uri.parse('http://192.168.164.141:8080/acceptDemandeAmis'),
        body: json.encode({
          'pseudo': widget.pseudo,
          'pseudoDemandeur': pseudoDemandeur,
          'accept': acceptDemandeAmi
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];
        print(message);
        // setState(() {});
      } else {
        print('Échec de la requête HTTP avec le code ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP : $e');
    }
  }

  void bloquerAmis(pseudoDemandeur) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/bloquerAmis'),
        // Uri.parse('http://192.168.164.141:8080/bloquerAmis'),
        body: json.encode({
          'pseudo': widget.pseudo,
          'pseudoDemandeur': pseudoDemandeur,
          'bloque': bloque
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];
        print(message);
        // setState(() {});
      } else {
        print('Échec de la requête HTTP avec le code ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP : $e');
    }
  }
}
