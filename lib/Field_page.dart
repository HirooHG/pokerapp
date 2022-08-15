import 'package:flutter/material.dart';
import 'game_communication.dart';

class FieldPage extends StatefulWidget{
  const FieldPage({super.key, required this.playerList});

  final List<dynamic> playerList;

  @override
  State<FieldPage> createState() => _FieldPageState();
}
class _FieldPageState extends State<FieldPage>{

  late double width;
  late double height;

  @override
  void initState(){
    super.initState();

    game.addListener(_onMessageReceived);
  }

  @override
  void dispose(){
    super.dispose();

    game.removeListener(_onMessageReceived);
  }

  _onMessageReceived(message){

  }

  @override
  Widget build(BuildContext context){

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        color: const Color(0xFF1F4E2E),
        height: height,
        width: width,
        child: Column(

        ),
      ),
    );
  }
}