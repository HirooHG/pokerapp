import 'package:flutter/material.dart';
import 'Lobbies_page.dart';
import 'game_communication.dart';

class LobbyPage extends StatefulWidget{
  const LobbyPage({super.key, required this.index});

  final int index;

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}
class _LobbyPageState extends State<LobbyPage>{

  late int index;
  late double width;
  late double height;

  List<dynamic> playersList = <dynamic>[];

  @override
  void initState(){
    super.initState();
    index = widget.index;

    game.addListener(_onMessageReceived);
    game.send("onEnterLobby", "$index");
  }
  @override
  void dispose(){
    super.dispose();
    game.removeListener(_onMessageReceived);
    game.send("onLeaveLobby", "$index");
  }

  _onMessageReceived(message){
    switch(message["action"]){
      case "onPlayerListInLobby":
        playersList = message["data"];
        setState(() {});
        break;
      case "onIndexChanged":
        index = message["data"] as int;
        setState(() {});
        break;
    }
  }

  Widget _playersList(){

    if (game.playerName == "") {
      return Container();
    }

    List<Widget> children = playersList.map((playerInfo) {
      return Card(
        child: ListTile(
            title: Text(playerInfo["name"]),
            trailing: game.playerId == playerInfo["id"] ? const Text("Me") : const SizedBox(width: 0, height: 0)
        ),
      );
    }).toList();

    return Column(
      children: children,
    );
  }

  @override
  Widget build(BuildContext context){

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: height * 0.3,
            child: Center(
              child: Text(
                "Lobby ${index + 1}",
                style: const TextStyle(
                  fontSize: 65,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
          Expanded(
            child: _playersList()
          )
        ],
      )
    );
  }
}