
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

//#region cards and colors
var linkAsset = "assets/cards/";
var couverture = "couverture.jpg";
var trefle = "trefles";
var carreau = "carreau";
var coeur = "coeur";
var pique = "pique";
var cards = [
  "A.jpg",
  "2.jpg",
  "3.jpg",
  "4.jpg",
  "5.jpg",
  "6.jpg",
  "7.jpg",
  "8.jpg",
  "9.jpg",
  "10.jpg",
  "J.jpg",
  "Q.jpg",
  "K.jpg"
];
var blinds = [
  "D",
  "SB",
  "BB",
];
var colorBlind = {
  "BB" : Colors.yellow,
  "SB" : Colors.red,
  "D" : Colors.white
};
//#endregion

class FieldPage extends StatefulWidget {
  const FieldPage({super.key, required this.playerList, required this.index});

  final List<dynamic> playerList;
  final int index;

  @override
  State<FieldPage> createState() => _FieldPageState();
}
class _FieldPageState extends State<FieldPage>{

  late List<Player> players;
  late double width;
  late double height;
  late int index;
  dynamic cardOne;
  dynamic cardTwo;

  int miseTotal = 0;
  int miseMax = 4;

  Me me = Me(playerName: game.playerName, total: game.playerTotal, id: game.playerId);
  River river = River();

  @override
  void initState(){
    super.initState();

    game.addListener(_onMessageReceived);
    index = widget.index;
    
    players = [
      for(var i in widget.playerList) if(i["id"] != game.playerId)
        Player(playerName: i["name"], total: i["total"] as int, id: i["id"])
    ];
    game.send("onEnterGame", "$index");
  }
  @override
  void dispose(){
    game.send("onLeaveGame", "$index");
    game.removeListener(_onMessageReceived);

    super.dispose();
  }

  Future<void> choices() async{

    bool canCheck = me.mise == miseMax;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actions: <Widget>[
            Wrap(
              children: [
                TextButton(
                  onPressed: () {

                  },
                  child: const Text('Fold'),
                ),
                if(canCheck) TextButton(
                  onPressed: () {

                  },
                  child: const Text('Check'),
                ),
                TextButton(
                  onPressed: () {

                  },
                  child: const Text('Raise'),
                ),
                if(!canCheck) TextButton(
                  onPressed: () {

                  },
                  child: const Text('Call'),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  _onMessageReceived(message){
    switch(message["action"]){
      case "onHandOutCards":
        setState(() {
          cardOne = message["data"]["cardOne"];
          cardTwo = message["data"]["cardTwo"];
          var linkOne = "$linkAsset${cardOne[0]}/${cardOne[1]}.jpg";
          var linkTwo = "$linkAsset${cardTwo[0]}/${cardTwo[1]}.jpg";
          me.getCards(linkOne, linkTwo);
        });
        break;

      case "onPlayerLeft":
        var idPlayer = message["data"];

        popup(context: context, text: idPlayer, title: idPlayer.runtimeType.toString());
        break;

      case "onReceiveBlind":
        setState(() {
          me.blind = message["data"] as String;
          me.mise = message["mise"] as int;
        });
        break;

      case "onReceiveBlindAll":
        setState(() {
          miseTotal = message["data"] as int;
        });
        break;
      case "onPlaying":

        break;
      case "onPlayerPlaying":
        setState(() {
          String idPlayerPlaying = message["id"];
          for (Player player in players) {
            if(player.id == idPlayerPlaying){
              player.isPlaying = true;
            }
          }
        });
        break;
      case "onChangeBlinds":
        setState(() {
          var dealerId = message["data"][0] as String;
          var smallBlindId = message["data"][1] as String;
          var bigBlindId;

          if((message["data"] as List<dynamic>).length >= 3) bigBlindId = message["data"][2] as String;

          players.forEach((player) {
            if(player.id == dealerId) player.blind = blinds[0];
            if(player.id == smallBlindId) player.blind = blinds[1];
            if(bigBlindId != null && player.id == bigBlindId) player.blind = blinds[2];
          });
        });
        break;
      case "onChangeMise":
        setState(() {
          var list = message["data"] as List<dynamic>;
          var ids = message["ids"] as List<dynamic>;
          for(int i = 0; i < list.length; i++){
            var mise = list[i];
            var id = ids[i];
            if(id == me.id) continue;
            var player;
            players.forEach((element) {
              if(element.id == id) player = element;
            });
            player.mise = mise;
          }
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context){

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var coef = 0.145;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Image.asset("assets/tapi.png").image,
            fit: BoxFit.cover
          )
        ),
        height: height,
        width: width,
        child: Column(
          children: [
            SizedBox(
              height: height * coef,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  (players.length >= 3) ? players[2].plateau(width, height) : River.empty(width, height),
                  (players.length >= 4) ? players[3].plateau(width, height) : River.empty(width, height),
                  (players.length >= 5) ? players[4].plateau(width, height) : River.empty(width, height),
                ],
              ),
            ),
            SizedBox(
              height: height * coef,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  (players.length >= 2) ? players[1].plateau(width, height) : River.empty(width, height),
                  (players.length >= 6) ? players[5].plateau(width, height) : River.empty(width, height),
                ],
              ),
            ),
            SizedBox(
              height: height * coef,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  (players.isNotEmpty) ? players[0].plateau(width, height) : River.empty(width, height),
                  Text(
                    miseTotal.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  (players.length >= 7)? players[6].plateau(width, height) : River.empty(width, height),
                ],
              ),
            ),
            SizedBox(
              height: height * 0.2,
              width: width,
              child: river.river(width, height),
            ),
            Expanded(
              child: me.plateau(width, height)
            )
          ],
        ),
      ),
    );
  }
}

class Player{

  Player({required this.playerName, required this.total, required this.id});

  final String playerName;
  final String id;

  int mise = 0;
  int total;
  String blind = "";
  bool isPlaying = false;

  Widget plateau(double width, double height){

    var widthBox = width * 0.25;
    var heightBox = height * 0.15;

    return SizedBox(
      width: widthBox,
      height: heightBox,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            playerName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: (!isPlaying) ? Colors.white : Colors.blue,
              fontSize: 18
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(linkAsset + couverture, fit: BoxFit.fill, width: widthBox / 2.55, height: heightBox / 2.55),
              Image.asset(linkAsset + couverture, fit: BoxFit.fill, width: widthBox / 2.55, height: heightBox / 2.55),
              Text(
                blind,
                style: TextStyle(
                  color: colorBlind[blind],
                  fontWeight: FontWeight.bold
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mise.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade100
                ),
              ),
              Text(
                total.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green
                ),
              ),
            ],
          )
        ],
      )
    );
  }
}
class Me extends Player{

  late String linkCardOne;
  late String linkCardTwo;

  Me({required super.playerName, required super.total, required super.id}){
    linkCardOne = linkAsset + couverture;
    linkCardTwo = linkAsset + couverture;
  }

  getCards(String a, String b){
    linkCardOne = a;
    linkCardTwo = b;
  }

  @override
  Widget plateau(double width, double height){
    double sizeBoxX = width * 0.35;
    double sizeBoxY = height * 0.25;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: colorBlind[blind],
                borderRadius: BorderRadius.circular(100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  blind,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                ),
              )
            ),
            SizedBox(
              height: height * 0.05,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  mise.toString(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  ),
                ),
              )
            ),
          ],
        ),
        SizedBox(
          width: width * 0.05,
        ),
        SizedBox(
          width: width * 0.75,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(linkCardOne, fit: BoxFit.fill, width: sizeBoxX, height: sizeBoxY),
                  Image.asset(linkCardTwo, fit: BoxFit.fill, width: sizeBoxX, height: sizeBoxY),
                ],
              ),
              SizedBox(
                child: Text(
                  total.toString(),
                  style: const TextStyle(
                      color: Colors.green,
                      fontSize: 30,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          )
        )
      ],
    );
  }
}
class River{

  Widget river(double width, double height){

    var widthImage = width * 0.15;
    var heightImage = height * 0.12;
    Color color = Colors.green;
    var cards = [
      Container(),
      Container(),
      Container(),
      Container(),
      Container(),
    ];

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: widthImage,
            height: heightImage,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border(
                top: BorderSide(color: color, width: 2, style: BorderStyle.solid),
                left: BorderSide(color: color, width: 2, style: BorderStyle.solid),
                bottom: BorderSide(color: color, width: 2, style: BorderStyle.solid),
                right: BorderSide(color: color, width: 2, style: BorderStyle.solid),
              ),
            ),
            child: cards[0],
          ),
          Container(
            width: widthImage,
            height: heightImage,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border(
                top: BorderSide(color: color, width: 2, style: BorderStyle.solid),
                left: BorderSide(color: color, width: 2, style: BorderStyle.solid),
                bottom: BorderSide(color: color, width: 2, style: BorderStyle.solid),
                right: BorderSide(color: color, width: 2, style: BorderStyle.solid),
              ),
            ),
            child: cards[1],
          ),
          Container(
            width: widthImage,
            height: heightImage,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border(
                top: BorderSide(color: color, width: 2, style: BorderStyle.solid),
                left: BorderSide(color: color, width: 2, style: BorderStyle.solid),
                bottom: BorderSide(color: color, width: 2, style: BorderStyle.solid),
                right: BorderSide(color: color, width: 2, style: BorderStyle.solid),
              ),
            ),
            child: cards[2],
          ),
          Container(
            width: widthImage,
            height: heightImage,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border(
                top: BorderSide(color: color, width: 2, style: BorderStyle.solid),
                left: BorderSide(color: color, width: 2, style: BorderStyle.solid),
                bottom: BorderSide(color: color, width: 2, style: BorderStyle.solid),
                right: BorderSide(color: color, width: 2, style: BorderStyle.solid),
              ),
            ),
            child: cards[3],
          ),
          Container(
            width: widthImage,
            height: heightImage,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border(
                top: BorderSide(color: color, width: 2, style: BorderStyle.solid),
                left: BorderSide(color: color, width: 2, style: BorderStyle.solid),
                bottom: BorderSide(color: color, width: 2, style: BorderStyle.solid),
                right: BorderSide(color: color, width: 2, style: BorderStyle.solid),
              ),
            ),
            child: cards[4],
          ),
        ],
      ),
    );
  }
  static Widget empty(double width, double height){

    var widthImage = width * 0.25;
    var heightImage = height * 0.09;
    Color color = Colors.red.shade300;

    return Container(

    );
  }
}