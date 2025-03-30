import 'dart:io';

import 'data_action.dart';
import 'join_room.dart';
import 'leave_room_controller.dart';
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
        final String roomID = "123";
        switch (action) {
          case DataAction.join:
          final username = data[1];
            JoinRoomController.joinRoom(username, rooms, socket, roomID);
            print("length: ${rooms[roomID]?.players.length}");
            break;
          case DataAction.move:
            rooms[roomID]!.players.forEach((username,player) {
            if (player != socket) {
                player.add(message);
              }
            });
            break;
          case DataAction.leave:
            final username = data[1];
            LeaveRoomController.leaveRoom(username, rooms, socket, roomID);
            print("length: ${rooms[roomID]?.players.length}");
            break;
          default:
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