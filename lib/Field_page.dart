
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
  "SM" : Colors.red,
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
  var miseTotal = 0;

  var me = Me(playerName: game.playerName, total: game.playerTotal);
  var river = River();

  @override
  void initState(){
    super.initState();

    game.addListener(_onMessageReceived);
    index = widget.index;
    
    players = [
      for(var i in widget.playerList) if(i["name"] != game.playerName) Player(playerName: i["name"], total: i["total"])
    ];
    game.send("onEnterGame", "$index");
  }
  @override
  void dispose(){
    game.removeListener(_onMessageReceived);
    game.send("onLeaveGame", "$index");

    super.dispose();
  }

  _onMessageReceived(message){
    switch(message["action"]){
      case "onHandOutCards":
        cardOne = message["data"]["cardOne"];
        cardTwo = message["data"]["cardTwo"];
        var linkOne = "$linkAsset${cardOne[0]}/${cardOne[1]}.jpg";
        var linkTwo = "$linkAsset${cardTwo[0]}/${cardTwo[1]}.jpg";
        me.getCards(linkOne, linkTwo);
        setState(() {});
        break;

      case "onPlayerLeft":
        var indexPlayer = message["data"] as int;
        players.removeAt(indexPlayer);
        widget.playerList.removeAt(indexPlayer);
        setState(() {});
        break;

      case "onReceiveBlind":
        var blind = message["data"] as String;
        var mise = message["mise"] as int;
        me.getMiseBlind(mise: mise, blind: blind);
        //setState(() {});
        print("${me.blind} ${me.mise}");
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
                  (players.length >= 7) ? players[6].plateau(width, height) : River.empty(width, height),
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

  late int mise;
  late String blind;
  int total;
  final String playerName;

  Player({required this.playerName, required this.total}){
    mise = 0;
    blind = "";
  }

  getMiseBlind({mise, blind}){
    this.mise = mise;
    this.blind = blind;
  }

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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18
            ),
          ),
          Row(
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

  Me({required super.playerName, required super.total}){
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
                  style: TextStyle(
                    color: Colors.grey.shade200,
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