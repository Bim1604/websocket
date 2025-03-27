import 'dart:io';

import 'room_model.dart';



void main() async {

  final port = 80;
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);

  print("WebSocket Server running at ws://${server.address.address}:$port");

  final List<WebSocket> clients = [];
  final Map<String, RoomModel> rooms = {};

  await for (HttpRequest request in server) {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      WebSocket socket = await WebSocketTransformer.upgrade(request);
      print("Client connected!");
      clients.add(socket);
      print('A new player connected. Total players: ${clients.length}');

      socket.listen((message) {
        socket.add("Server received: $message");
        final data = message.split(':'); 
        final action = data[0];
        final roomID = data[1];
        if (action == "join") {
          rooms.putIfAbsent(roomID, () => RoomModel(id: roomID));
          rooms[roomID]!.players.add(socket);

          if (rooms[roomID]!.players.length == 2) {
              rooms[roomID]!.players.forEach((player) {
              player.add('start:$roomID');
            });
          }
          print("Room count: ${rooms[roomID]?.players.length}");
        } else if (action == "move") {
          rooms[roomID]!.players.forEach((player) {
            if (player != socket) {
              player.add(message);
            }
          });
        }
      }, onDone: () {
          rooms.forEach((key, room) {
            room.players.remove(socket);
            if (room.players.isEmpty) {
              rooms.remove(key);
            }
          });
          print("Room count: ${rooms.length}");
          clients.remove(socket);
          print('A player disconnected. Total players: ${clients.length}');
        },
        onError: (error) {
          print('Error: $error');
          clients.remove(socket);
        },);

    } else {
      request.response.statusCode = HttpStatus.forbidden;
      request.response.close();
    }
  }
}