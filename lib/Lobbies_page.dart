
import 'package:flutter/material.dart';
import 'game_communication.dart';
import 'lobby_page.dart';

Future<void> popup({String? title = "", String? text = "", required BuildContext context}) async{

  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title!),
        content: Text(
          text!,
          style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 15
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

class LobbiesPage extends StatefulWidget{
  const LobbiesPage({super.key});

  @override
  State<LobbiesPage> createState() => LobbiesPageState();
}
class LobbiesPageState extends State<LobbiesPage>{

  List<dynamic> lobbiesList = <dynamic>[];

  late double width;
  late double height;

  @override
  void initState(){
    super.initState();

    game.addListener(_onMessageReceived);
    game.send("search_lobby", "");
  }

  @override
  void dispose(){
    super.dispose();

    game.removeListener(_onMessageReceived);
  }

  _onMessageReceived(message){
    switch(message["action"]){
      case 'lobbies_list':
        lobbiesList = message["data"];
        setState(() {});
        break;
      case "onjoinlobby":
        var index = message["data"];
        Navigator.push(context, MaterialPageRoute(builder: (context) => LobbyPage(index: index)));
        break;
    }
  }

  Widget _lobbiesList(){

    if(lobbiesList.isEmpty) return Container();

    List<Widget> children = lobbiesList.map((lobby) {
      int index = lobby["index"] as int;
      int numberofplayer = lobby["numberOfPlayer"] as int;
      int number = index + 1;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Card(
          elevation: 20.0,
          child: ListTile(
              title: Text(
                "Lobby $number",
                style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 30,
                    fontWeight: FontWeight.bold
                ),
              ),
              isThreeLine: true,
              subtitle: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text("number of player : $numberofplayer"),
                ),
              ),
              trailing: Container(
                width: width * 0.3,
                color: Colors.blue,
                child: TextButton(
                  child: const Text("Join", style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    game.send("onjoinlobby", "$index");
                  },
                ),
              )
          ),
        )
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, height * 0.1, 0, height * 0.05),
              child: const Text(
                'List of Lobbies:',
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 40,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
            Container(
              color: Colors.blue,
              child: TextButton(
                onPressed: () {
                  game.send("onjoinlobby", "-1");
                },
                child: const Text("New Lobby", style: TextStyle(color: Colors.white)),
              ),
            ),
            _lobbiesList(),
          ],
        ),
      )
    );
  }
}