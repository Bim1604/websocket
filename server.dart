import 'dart:io';

import 'room_model.dart';



void main() async {

  final port = 80;
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);

  print("WebSocket Server running at ws://${server.address.address}:$port");

  final Map<String, RoomModel> rooms = {};

  await for (HttpRequest request in server) {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      WebSocket socket = await WebSocketTransformer.upgrade(request);
      print("Client connected!");

      socket.listen((message) {
        socket.add("Server received: $message");
        final data = message.split(':'); 
        final action = data[0];
        final roomID = data[1];
        if (action == "join") {
          rooms.putIfAbsent(roomID, () => RoomModel(id: roomID));
          if (rooms[roomID]!.players.length == 2) {
            socket.add("Room is full"); /// send mes to client
            print("Room ${roomID} is full");
            return;
          }
          rooms[roomID]!.players.add(socket);

          if (rooms[roomID]!.players.length == 2) {
              rooms[roomID]!.players.forEach((player) {
              player.add('start:$roomID');
              print("Start room ${roomID}");
            });
          }
          print("Room ${roomID} player: ${rooms[roomID]?.players.length}");
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
          print("Client disconnected");
          print("Room count: ${rooms.length}");
        },
        onError: (error) {
          print('Error: $error');
        },);

    } else {
      request.response.statusCode = HttpStatus.forbidden;
      request.response.close();
    }
  }
}