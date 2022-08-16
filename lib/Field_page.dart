import 'dart:ui';

import 'package:flutter/material.dart';
import 'game_communication.dart';

String linkAsset = "assets/cards/";
String couverture = "couverture.jpg";

var trefle = "trefles/";
var carreau = "carreau/";
var coeur = "coeur/";
var pique = "pique/";

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
  "BB",
  "SB",
  "D"
];
Map<String, MaterialColor> colorBlind = {
  "BB" : Colors.yellow,
  "SM" : Colors.red,
  "D" : Colors.blue
};

class FieldPage extends StatefulWidget{
  const FieldPage({super.key, required this.playerList});

  final List<dynamic> playerList;

  @override
  State<FieldPage> createState() => _FieldPageState();
}
class _FieldPageState extends State<FieldPage>{

  late double width;
  late double height;

  var players = [
    Player(),
    Player(),
    Player(),
    Player(),
    Player(),
    Player(),
    Player(),
  ];
  Me me = Me();
  River river = River();

  @override
  void initState(){
    super.initState();

    game.addListener(_onMessageReceived);
  }

  @override
  void dispose(){
    game.removeListener(_onMessageReceived);

    super.dispose();
  }

  _onMessageReceived(message){

  }

  @override
  Widget build(BuildContext context){

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var coef = 0.19;

    return Scaffold(
      body: Container(
        color: const Color(0xFF1F4E2E),
        height: height,
        width: width,
        child: Column(
          children: [
            Container(
              height: height * coef,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  players[2].plateau(width, height),
                  players[3].plateau(width, height),
                  players[2].plateau(width, height),
                ],
              ),
            ),
            Container(
              height: height * coef,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Transform(
                    transform: Matrix4.rotationZ(80.11),
                    alignment: Alignment.center,
                    child: players[1].plateau(width, height),
                  ),
                  river.riverTop(width, height),
                  Transform(
                    transform: Matrix4.rotationZ(-80.11),
                    alignment: Alignment.center,
                    child: players[5].plateau(width, height),
                  )
                ],
              ),
            ),
            Container(
              height: height * coef,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Transform(
                    transform: Matrix4.rotationZ(80.11),
                    alignment: Alignment.center,
                    child: players[0].plateau(width, height),
                  ),
                  river.riverBot(width, height),
                  Transform(
                    transform: Matrix4.rotationZ(-80.11),
                    alignment: Alignment.center,
                    child: players[6].plateau(width, height),
                  )
                ],
              ),
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

  int mise = 10;
  int total = 2000;

  Widget plateau(double width, double height){

    var widthBox = width * 0.25;
    var heightBox = height * 0.15;

    return Container(
      //color: Colors.red,
      width: widthBox,
      height: heightBox,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            total.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
          Row(
            children: [
              Image.asset(linkAsset + couverture, fit: BoxFit.fill, width: widthBox / 2, height: heightBox / 2),
              Image.asset(linkAsset + couverture, fit: BoxFit.fill, width: widthBox / 2, height: heightBox / 2)
            ],
          ),
          Text(
            mise.toString(),
            style: const TextStyle(
                fontWeight: FontWeight.bold
            ),
          ),
        ],
      )
    );
  }
}
class Me extends Player{

  @override
  Widget plateau(double width, double height){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: colorBlind["BB"],
                borderRadius: BorderRadius.circular(100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  blinds[0],
                  style: const TextStyle(
                    color: Colors.grey,
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
                  Image.asset(linkAsset + trefle + cards[0], fit: BoxFit.fill, width: 150, height: 200),
                  Image.asset(linkAsset + couverture, fit: BoxFit.fill, width: 150, height: 200)
                ],
              ),
              SizedBox(
                child: Text(
                  total.toString(),
                  style: const TextStyle(
                      color: Colors.blue,
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

  Widget riverTop(double width, double height){

    var widthImage = width * 0.15;
    var heightImage = height * 0.12;

    return Container(
      child: Row(
        children: [
          Image.asset(linkAsset + couverture, fit: BoxFit.fill, width: widthImage, height: heightImage),
          Image.asset(linkAsset + couverture, fit: BoxFit.fill, width: widthImage, height: heightImage),
          Image.asset(linkAsset + couverture, fit: BoxFit.fill, width: widthImage, height: heightImage),
        ],
      ),
    );
  }
  Widget riverBot(double width, double height){

    var widthImage = width * 0.14;
    var heightImage = height * 0.12;

    return Container(
      child: Row(
        children: [
          Image.asset(linkAsset + couverture, fit: BoxFit.fill, width: widthImage, height: heightImage),
          Image.asset(linkAsset + couverture, fit: BoxFit.fill, width: widthImage, height: heightImage),
        ],
      ),
    );
  }
}