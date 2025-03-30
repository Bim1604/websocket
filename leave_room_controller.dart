import 'dart:io';

import 'data_action.dart';
import 'room_model.dart';

class LeaveRoomController {

  static void leaveRoom(String username, Map<String, RoomModel> rooms, WebSocket socket, String roomID) {
    rooms[roomID]!.players.remove(username);
    print("Username ${username} left room ${roomID}");
    socket.add("${DataAction.leave}:${DataActionStatus.sc}");
    if (rooms[roomID]!.players.isEmpty) {
      rooms.remove(roomID);
      print("Room ${roomID} is removed");
    }
  }
}