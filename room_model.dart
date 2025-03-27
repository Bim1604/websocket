import 'dart:io';

class RoomModel {
  String? id;
  List<WebSocket> players = [];

  RoomModel({this.id});
}