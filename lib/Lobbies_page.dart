
import 'package:flutter/material.dart';
import 'game_communication.dart';

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
      case 'alreadyIn':
        popup(context: context, text: "already in !", title: "yay !");
        break;
    }
  }

  Widget _lobbiesList(){

    if(lobbiesList.isEmpty) return Container();

    List<Widget> children = lobbiesList.map((lobby) {
      int number = lobby["index"] as int;
      int numberofplayer = lobby["numberofplayer"] as int;
      number++;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: ListTile(
          title: Text(
            "Lobby $number",
            style: const TextStyle(
                color: Colors.blue,
                fontSize: 20
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
            color: Colors.blue,
            child: TextButton(
              child: const Text("Join", style: TextStyle(color: Colors.white)),
              onPressed: () {
                game.send("onjoinlobby", "${number - 1}");

                //go to the lobby
                //Navigator.push(context, MaterialPageRoute(builder: (context) => ));
              },
            )
          )
        )
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
                  game.send("new_lobby", "");
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