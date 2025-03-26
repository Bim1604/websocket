import 'dart:io';
import 'dart:convert';

void main() async {
  const int port = 8080;
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print('WebSocket server is running on ws://172.16.0.255:$port');

  final List<WebSocket> clients = [];

  await for (HttpRequest request in server) {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      WebSocket socket = await WebSocketTransformer.upgrade(request);
      clients.add(socket);
      print('A new player connected. Total players: ${clients.length}');

      // Listen for messages from clients
      socket.listen(
            (data) {
          // Forward message to all clients
          for (var client in clients) {
            if (client != socket) {
              client.add(data);
            }
          }
        },
        onDone: () {
          clients.remove(socket);
          print('A player disconnected. Total players: ${clients.length}');
        },
        onError: (error) {
          print('Error: $error');
          clients.remove(socket);
        },
      );
    } else {
      request.response
        ..statusCode = HttpStatus.forbidden
        ..write('WebSocket connections only')
        ..close();
    }
  }
}
