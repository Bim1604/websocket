import 'dart:io';

void main() async {

  final port = 80;
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);

  print("WebSocket Server running at ws://${server.address.address}:$port");

  final List<WebSocket> clients = [];

  await for (HttpRequest request in server) {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      WebSocket socket = await WebSocketTransformer.upgrade(request);
      print("Client connected!");
      clients.add(socket);
      print('A new player connected. Total players: ${clients.length}');

      socket.listen((data) {
        print("Received: $data");
        socket.add("Server received: $data");
        for (var client in clients) {
            if (client != socket) {
              client.add(data);
            }
          }
        print('A new player connected. Total players: ${clients.length}');
      }, onDone: () {
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