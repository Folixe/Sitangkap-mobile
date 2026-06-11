import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';

class SocketService {
  SocketService._internal();
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  IOWebSocketChannel? _channel;
  final StreamController<dynamic> _controller = StreamController<dynamic>.broadcast();

  Stream<dynamic> get stream => _controller.stream;

  Future<void> connect({String? url}) async {
    final socketUrl = url ?? 'ws://127.0.0.1:6000/ws';
    try {
      _channel = IOWebSocketChannel.connect(Uri.parse(socketUrl));
      _channel?.stream.listen((message) {
        try {
          final parsed = jsonDecode(message);
          _controller.add(parsed);
        } catch (_) {
          _controller.add(message);
        }
      }, onError: (err) {
        // forward error
        _controller.addError(err);
      }, onDone: () {
        // try reconnect later? leave to caller
      });
    } catch (e) {
      // connection failed
      _controller.addError(e);
    }
  }

  void disconnect() {
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  void send(dynamic data) {
    try {
      final payload = data is String ? data : jsonEncode(data);
      _channel?.sink.add(payload);
    } catch (_) {}
  }

  void dispose() {
    disconnect();
    _controller.close();
  }
}
