import 'package:flutter/material.dart';
import 'game_communication.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key, required this.number});

  final int number;

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}
class _LobbyPageState extends State<LobbyPage>{

  @override
  void initState(){
    super.initState();

  }

  @override
  void dispose(){
    super.dispose();


  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {

          },
          child: const Text("test"),
        ),
      )
    );
  }
}