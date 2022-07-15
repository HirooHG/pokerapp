import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';

WebSocketsNotifications sockets = WebSocketsNotifications();

const String _serverAdress = "ws://192.168.8.10:34263";

class WebSocketsNotifications {
  static final WebSocketsNotifications _sockets = WebSocketsNotifications._internal();

  factory WebSocketsNotifications(){
    return _sockets;
  }

  WebSocketsNotifications._internal();
  IOWebSocketChannel? _channel;
  bool _isOn = false;
  final _listeners = ObserverList<Function>();

  initCommunication() async {

    reset();

    try {
      _channel = IOWebSocketChannel.connect(_serverAdress);
      _channel!.stream.listen(_onReceptionOfMessageFromServer);
    } catch(e){
      //
    }
  }
  reset(){
    if (_channel != null){
      _channel!.sink.close();
      _isOn = false;
    }
  }
  send(String message){
    if (_channel != null){
      if (_isOn){
        _channel!.sink.add(message);
      }
    }
  }
  addListener(Function callback){
    _listeners.add(callback);
  }
  removeListener(Function callback){
    _listeners.remove(callback);
  }
  _onReceptionOfMessageFromServer(message){
    _isOn = true;
    for(var i in _listeners){
      i(message);
    }
  }
}