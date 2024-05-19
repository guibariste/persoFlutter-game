import 'package:socket_io_client/socket_io_client.dart';

class SocketIoManager {
  late Socket socket;

  void initializeSocket() {
    socket = io("http://localhost:8081", <String, dynamic>{
      'transports': ['websocket'], // Utilisez WebSocket comme transport
    });
    socket.connect();
  }

  void sendFormData(Map<String, dynamic> formData) {
    // Envoyez les données au serveur Socket.io
    socket.emit('formInscription', formData);
  }

  void sendFormConnexion(Map<String, dynamic> formData) {
    // Envoyez les données au serveur Socket.io
    socket.emit('formConnexion', formData);
  }

  void sendScore(Map<String, dynamic> formData) {
    // Envoyez les données au serveur Socket.io
    socket.emit('score', formData);
  }

  void sendGetHighestScoreFacile(Map<String, dynamic> formData) {
    // Envoyez les données au serveur Socket.io
    socket.emit('getHighestScoreFacile', formData);
  }

  void sendGetHighestScoreDifficile(Map<String, dynamic> formData) {
    // Envoyez les données au serveur Socket.io
    socket.emit('getHighestScoreDifficile', formData);
  }

  void sendGetHighestScores(Map<String, dynamic> formData) {
    // Envoyez les données au serveur Socket.io
    socket.emit('getHighestScores', formData);
  }

  void listenForConnexionResult(Function(bool, String) callback) {
    socket.on('resultConnexion', (data) {
      bool success = data['success'];
      String message = data['message'];
      print(success);
      callback(success, message);
    });
  }

  // Future<int> scoreFacile(Function(int) callback) async {
  //   socket.on('highestScoreFacile', (data) {
  //     callback(data);
  //   });

  // }
  // Future<void> listenForHighestScoreFacile(Function(int) callback) async {
  //   socket.on('highestScoreFacile', (data) {
  //     callback(data);
  //   });
  // }

  Future<int> scoreDifficile(Function(int) callback) async {
    socket.on('highestScoreDifficile', (data) {
      callback(data);
    });
    return 0;
  }

  void scoreFacile(Function(int) callback) {
    socket.on('highestScoreFacile', (data) {
      callback(data);
    });
  }

  void listenForHighestScores(Function(Map<String, dynamic>) callback) {
    socket.on('highestScores', (data) {
      callback(data);
    });
  }

  void sendPseudoProfil(String pseudo) {
    // Envoyez les données au serveur Socket.io
    socket.emit('getProfil', pseudo);
  }

  void getProfil() {
    socket.on('profil', (data) {
      print(data);
    });
  }

  void closeSocket() {
    socket.disconnect();
  }
}
