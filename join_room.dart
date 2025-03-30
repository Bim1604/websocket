import 'dart:io';

import 'data_action.dart';
import 'room_model.dart';

class JoinRoomController {
  static void joinRoom(String username, Map<String, RoomModel> rooms, WebSocket socket, String roomID) {

    rooms.putIfAbsent(roomID, () => RoomModel(id: roomID));
    if (rooms[roomID]!.players.length == 2) {
      socket.add("Room is full");
      print("Room ${roomID} is full");
      return;
    }

    if (rooms[roomID]!.players.containsKey(username)) {
      socket.add("$username is joined}");
      print("Username ${username} is already taken");
      return;
    }

    rooms[roomID]!.players.putIfAbsent(username, () => socket);

    if (rooms[roomID]!.players.length == 2) {
      rooms[roomID]!.players.forEach((username, player) {
        player.add('${DataAction.start}:$roomID');
      });
      print("Start room ${roomID}");
    }
    print("Room ${roomID} player: ${rooms[roomID]?.players.length}");
  }
}
