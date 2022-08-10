import 'package:flutter/material.dart';
import 'Lobbies_page.dart';
import 'game_communication.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key, required this.number});

  final int number;

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}
class _LobbyPageState extends State<LobbyPage>{

  List<dynamic> playersList = <dynamic>[];

  @override
  void initState(){
    game.addListener(_onGameDataReceived);
    game.send("enter_lobby", "${widget.number}");

    super.initState();

  }

  @override
  void dispose(){
    game.send("leave_lobby", "${widget.number}");

    super.dispose();
  }

  _onGameDataReceived(message){

    switch (message["action"]) {
      case "players_list_lobby":
        var number = int.tryParse(message["number"]);

        if(number == widget.number){
          playersList = message["data"];
          setState(() {});
        }
        break;
    }
  }

  Widget _playersList(){

    if (game.playerName == "") {
      return Container();
    }

    List<Widget> children = playersList.map((playerInfo) {
      return ListTile(
          title: Text(
            playerInfo["name"],
            style: const TextStyle(
              fontSize: 25
            ),
          ),
          trailing: game.playerId == playerInfo["id"] ? const Text("Me") : const SizedBox(width: 0, height: 0)
      );
    }).toList();

    return Column(
      children: children,
    );
  }

  @override
  Widget build(BuildContext context){

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: height * 0.3,
              child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lobby ${widget.number + 1}',
                        style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 80,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      const Text(
                        'players :',
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 30
                        ),
                      ),
                    ],
                  )
              ),
            ),
            _playersList()
          ],
        ),
      )
    );
  }
}