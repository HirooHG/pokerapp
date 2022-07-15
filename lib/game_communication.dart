import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'websocket.dart';

final game = GameCommunication();

class GameCommunication {
  static final GameCommunication _game = GameCommunication._internal();
  final _listeners = ObserverList<Function>();

  String _playerName = "";
  String _playerID = "";
  int _playerPoint = 0;

  String get playerName => _playerName;
  String get playerId => _playerID;

  factory GameCommunication(){
    return _game;
  }
  GameCommunication._internal(){

    sockets.initCommunication();
    sockets.addListener(_onMessageReceived);
  }

  _onMessageReceived(serverMessage){
    Map message = json.decode(serverMessage);

    switch(message["action"]){
      case 'connect':
        _playerID = message["data"];
        _playerPoint = message["points"] as int;
        break;

      default:
        for(var i in _listeners){
          i(message);
        }
        break;
    }
  }
  send(String action, String data){

    int other = 0;

    if (action == 'join'){
      _playerName = data;
      other = _playerPoint;
    }


    sockets.send(json.encode({
      "action": action,
      "data": data,
      "other": other
    }));
  }
  addListener(Function callback){
    _listeners.add(callback);
  }
  removeListener(Function callback){
    _listeners.remove(callback);
  }
}