import 'dart:io';

class RoomModel {
  String? id;
  Map<String, WebSocket> players = {};

  RoomModel({this.id});
}