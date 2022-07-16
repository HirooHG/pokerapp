import 'package:flutter/material.dart';
import 'game_communication.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}
class _StartPageState extends State<StartPage> {
  static final TextEditingController _name = TextEditingController();
  late String playerName;
  List<dynamic> playersList = <dynamic>[];

  @override
  void initState(){
    super.initState();
    game.addListener(_onGameDataReceived);
  }

  @override
  void dispose(){
    game.send("close", "");
    game.removeListener(_onGameDataReceived);
    super.dispose();
  }

  _onGameDataReceived(message){
    switch (message["action"]) {
      case "players_list":
        playersList = message["data"];

        setState(() {});
        break;
    }
  }
  _onGameJoin(){
    game.send('join', _name.text);

    setState(() {});
  }

  Widget _playersList(){

    if (game.playerName == "") {
      return Container();
    }

    List<Widget> children = playersList.map((playerInfo) {
      return ListTile(
        title: Text(playerInfo["name"]),
        trailing: game.playerId == playerInfo["id"] ? const Text("Me") : TextButton(
          onPressed: (){

          },
          child: const Text('Play'),
        ),
      );
    }).toList();

    return Column(
      children: children,
    );
  }
  Widget _buildJoin(){
    if (game.playerName != "") {
      return Container();
    }
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          TextField(
            controller: _name,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32.0),
              ),
              icon: const Icon(Icons.person),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: _onGameJoin,
              child: const Text('Join...'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TicTacToe'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _buildJoin(),
              const Text('List of players:'),
              _playersList(),
            ],
          ),
        ),
      ),
    );
  }
}