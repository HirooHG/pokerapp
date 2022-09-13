// region server settings

const port = 34264;
const webSocketServer = require('websocket').server;
const http = require('http');
const server = http.createServer(function(request, response) {});

server.listen(port, function() {
    console.log((new Date()) + " Serveur à l'écoute du port "  + port);
});

const wsServer = new webSocketServer({
    httpServer: server
});

//endregion

class Player{
    constructor(id, connection) {
        this.id = id;
        this.connection = connection;
        this.name = "";
        this.total = 0;

        this.index = undefined;
        this.indexInLobby = undefined;
        this.indexLobby = undefined;
        this.cards = undefined;
        this.blind = undefined;
        this.mise = undefined;
    }
    getId(){
        return {name: this.name, id: this.id, total: this.total};
    }
}
class Lobby{
    constructor() {
        this.players = [];
        this.isClosed = false;
        this.index = undefined;
    }
    getJson(){
        return {index: this.index, numberOfPlayer: this.players.length, isClosed: this.isClosed};
    }
}
class Poker{

    constructor() {
        this.players = [];
        this.lobbies = [];
        this.cards = [
          "A",
          "2",
          "3",
          "4",
          "5",
          "6",
          "7",
          "8",
          "9",
          "10",
          "J",
          "Q",
          "K"
        ];
        this.types = [
          "pique",
          "trefles",
          "coeur",
          "carreau"
        ];
        this.blinds = [
          "D",
          "SB",
          "BB",
        ];
        this.miseTotal = 0;
        this.miseMax = 0;
        this.blind = undefined;
        this.isGameEnded = false;
        this.playerPlaying = -1;
    }

    pushPlayer(player){
        player.index = this.players.length;
        this.players.push(player);
    }
    popPlayer(player){
        this.players.splice(player.index ,1);
        this.replaceIndexesPlayers()
    }
    pushLobby(lobby){
        lobby.index = this.lobbies.length;
        this.lobbies.push(lobby);
    }
    popLobby(lobby){
        this.lobbies.splice(lobby.index,1);
        this.replaceIndexesLobbies();
    }
    pushPlayerInLobby(lobby, player){
        player.indexInLobby = lobby.players.length;

        lobby.players.push(player);

        player.indexLobby = lobby.index;
    }
    popPlayerInLobby(lobby, player){
        lobby.players.splice(player.indexInLobby, 1);
        player.indexLobby = undefined;
        player.indexInLobby = undefined;
        this.replaceIndexesPlayersInLobbies();
    }

    onClose(player){
        this.lobbies.forEach((lobby) => {
            lobby.players.forEach((player1) => {
                if(player.id === player1.id) this.popPlayerInLobby(lobby, player);
            });
        });
        this.popPlayer(player);

        this.broadcastPlayersList();
        this.broadcastLobbiesList();
    }
    onDeleteLobby(index){
        let lobby = this.lobbies[index];

        this.popLobby(lobby);

        this.replaceIndexesLobbies();
        this.broadcastLobbiesList();
        this.sendChangesInLobbies();
        this.sendChangesInLobbies();
    }
    onJoinLobby(player, index){
        if(!this.lobbies.some((lobbyIn) => lobbyIn.players.some((playerIn) => playerIn.id === player.id))){

            let indexLobby = Number(index);

            if(indexLobby === -1){
                let lobby = new Lobby();
                this.pushLobby(lobby);
                indexLobby = lobby.index;

                this.pushPlayerInLobby(lobby, player);
            }
            else {
                let lobby = this.lobbies[indexLobby];
                this.pushPlayerInLobby(lobby, player);
            }

            this.broadcastLobbiesList();

            let message = JSON.stringify({
                'action': 'onjoinlobby',
                'data': indexLobby
            });

            player.connection.sendUTF(message);
        }
    }
    onLeaveLobby(player, index){
        let indexLobby = Number(index);
        let lobby = this.lobbies[indexLobby];
        this.popPlayerInLobby(lobby, player);

        this.broadcastLobbiesList();
        this.broadcastPlayersInLobbiesList(indexLobby);
        this.sendChangesInLobbies();
    }
    onGameBegin(index){
        index = Number(index);

        let lobby = this.lobbies.at(Number(index));
        lobby.isClosed = true;
        lobby.players.forEach((player) => {
            player.connection.sendUTF(JSON.stringify({"action" : "onGameBegin", "data" : ""}));
        });
        this.broadcastLobbiesList();
    }
    onEnterGame(index){
        index = Number(index);
        let lobby = this.lobbies[index];

        this.handOutCards(index);

        this.handOutBlinds(index);

        let player = lobby.players.find(player => player.blinds === "D");

        this.playerPlaying = lobby.players[(this.blind["dealer"]).indexInLobby + 1];
        lobby.players.forEach((player) => {
           console.log(player.index);
           console.log(player.blind);
        });
        this.playerPlaying.connection.sendUTF(JSON.stringify({"action": "onPlaying"}));

        this.lobbies.forEach((player) => {
            if(player.index !== this.playerPlaying) player.connection.sendUTF(JSON.stringify({"action": "onPlayerPlaying", "id": this.playerPlaying.id}));
        });
    }
    onLeaveGame(player, index){
        let indexPlayer = player.indexInLobby;
        let lobby = this.lobbies[index];

        player.cards = undefined;
        player.indexInLobby = undefined;
        player.indexLobby = undefined;

        this.popPlayerInLobby(lobby, player);

        lobby.players.forEach((playerIn) => {
            playerIn.connection.sendUTF(JSON.stringify({"action": "onPlayerLeft", "data" : indexPlayer}));
        });

        player.connection.sendUTF(JSON.stringify({"action" : "onPlayerLeaveLobby"}));

        this.broadcastLobbiesList();
    }

    broadcastPlayersList(){
        let playersList = [];

        this.players.forEach(function(player){
            if (player.name !== ''){
                playersList.push(player.getId());
            }
        });

        let message = JSON.stringify({
            'action': 'players_list',
            'data': playersList
        });

        this.players.forEach(function(player){
            player.connection.sendUTF(message);
        });
    }
    broadcastLobbiesList(){

        this.lobbies.forEach((lobby) => {
            if(lobby.players.length === 0){
                this.popLobby(lobby);
            }
        })
        this.replaceIndexesLobbies();
        this.sendChangesInLobbies();

        let lobbies = []

        this.lobbies.forEach(function(lobby) {
            lobbies.push(lobby.getJson());
        });

        let message = JSON.stringify({
            'action': 'lobbies_list',
            'data': lobbies
        });

        this.players.forEach(function(player){
            player.connection.sendUTF(message);
        });
    }
    broadcastPlayersInLobbiesList(indexLobby){

        let playersList = [];
        let index = Number(indexLobby);

        this.lobbies.forEach(function(lobby){
            if(lobby.index === index){
                lobby.players.forEach(function(player){
                    playersList.push(player.getId());
                });

                let message = JSON.stringify({
                    'action': 'onPlayerListInLobby',
                    'data': playersList
                });

                lobby.players.forEach(function(player){
                    player.connection.sendUTF(message);
                });
            }
        });
    }

    replaceIndexesPlayers(){
        this.players.forEach(function (player, index){
            player.index = index;
        });
    }
    replaceIndexesLobbies(){
        this.lobbies.forEach(function (lobby, index){
           lobby.index = index;
        });
    }
    replaceIndexesPlayersInLobbies(){
        this.lobbies.forEach(function (lobby, indexLobby){
            lobby.players.forEach(function(player, indexPlayer){
               player.indexInLobby = indexPlayer;
               player.indexLobby = indexLobby;
            });
        });
    }

    sendChangesInLobbies(){
        this.lobbies.forEach(function(lobby, index){
            lobby.players.forEach(function(player){
                const message = JSON.stringify({
                    action: "onIndexChanged",
                    data: index
                });
                player.connection.sendUTF(message);
            });
        });
    }
    verifSameCards(cardOne, cardTwo, lobby){

        let isSame = false;
        lobby.players.forEach((player) => {
            if(player.cards !== undefined){
                if(player.cards[0][0] === cardOne[0] && player.cards[0][1] === cardOne[1] || player.cards[1][0] === cardTwo[1] && player.cards[1][1] === cardTwo[1]){
                    isSame = true;
                }
            }
        });
        return isSame;
    }
    handOutCards(index){
        let lobby = this.lobbies[index];
        lobby.players.forEach((player) => {

            let typeOne;
            let cardOne;
            let typeTwo;
            let cardTwo;

            let cardTypeOne;
            let cardTypeTwo;

            do{
                typeOne = this.types[this.getRndInteger(0, this.types.length)];
                cardOne = this.cards[this.getRndInteger(0, this.cards.length)];

                typeTwo = this.types[this.getRndInteger(0, this.types.length)];
                cardTwo = this.cards[this.getRndInteger(0, this.cards.length)];

                cardTypeOne = [
                    typeOne,
                    cardOne
                ];
                cardTypeTwo = [
                    typeTwo,
                    cardTwo
                ];
            }while (cardOne !== cardTwo && typeOne !== typeTwo && !this.verifSameCards(cardTypeOne, cardTypeTwo, lobby));

            let message = JSON.stringify(
                {
                        "action" : "onHandOutCards",
                    "data" : {
                        "cardOne": cardTypeOne,
                        "cardTwo": cardTypeTwo
                    }
                }
            );
            player.cards = [
                cardOne,
                cardTwo
            ];
            player.connection.sendUTF(message);
        });
    }
    handOutBlinds(index){
        index = Number(index);
        let lobby = this.lobbies[index];
        let dealer;
        let smallBlind;
        let bigBlind;

        switch (lobby.players.length){
            case 2:
                dealer = lobby.players[0];
                smallBlind = lobby.players[1];

                dealer.connection.sendUTF(JSON.stringify({"action" : "onReceiveBlind", "data" : this.blinds[0], "mise": 0}));
                smallBlind.connection.sendUTF(JSON.stringify({"action" : "onReceiveBlind", "data" : this.blinds[1], "mise": 2}));

                dealer.blind = this.blinds[0];
                smallBlind.blind = this.blinds[1];
                break;
            case 3:

                dealer = lobby.players[0];
                smallBlind = lobby.players[1];
                bigBlind = lobby.players[2];

                dealer.connection.sendUTF(JSON.stringify({"action" : "onReceiveBlind", "data" : this.blinds[0], "mise": 0}));
                smallBlind.connection.sendUTF(JSON.stringify({"action" : "onReceiveBlind", "data" : this.blinds[1], "mise": 2}));
                bigBlind.connection.sendUTF(JSON.stringify({"action" : "onReceiveBlind", "data" : this.blinds[2], "mise": 4}));

                dealer.blind = this.blinds[0];
                smallBlind.blind = this.blinds[1];
                bigBlind.blind = this.blinds[2];
                break;
            default:
                let dealerInt = this.getRndInteger(0, lobby.players.length);
                let smallBlindInt = (dealerInt + 1 >= lobby.players.length) ? 0 : dealerInt + 1;
                let bigBlindInt = (smallBlindInt + 1 >= lobby.players.length) ? 0 : smallBlindInt + 1;

                dealer = lobby.players[dealerInt];
                smallBlind = lobby.players[smallBlindInt];
                bigBlind = lobby.players[bigBlindInt];

                dealer.connection.sendUTF(JSON.stringify({"action" : "onReceiveBlind", "data" : this.blinds[0], "mise": 0}));
                smallBlind.connection.sendUTF(JSON.stringify({"action" : "onReceiveBlind", "data" : this.blinds[1], "mise": 2}));
                bigBlind.connection.sendUTF(JSON.stringify({"action" : "onReceiveBlind", "data" : this.blinds[2], "mise": 4}));

                lobby.players.forEach((player) => player.connection.sendUTF({"action" : "onReceiveBlindAll", "data": this.miseTotal}));
                break;
        }
        this.blind = {
            "dealer" : dealer,
            "smallBlind" : smallBlind,
            "bigBlind": bigBlind
        };
        dealer.mise = 0;
        smallBlind.mise = 2;
        if(bigBlind != null) bigBlind.mise = 4;
    }
    getRndInteger(min, max){
        return Math.floor(Math.random() * (max - min) ) + min;
    }
}

const poker = new Poker();

wsServer.on('request', (request) => {

    let connection = request.accept(null, request.origin);
    let player = new Player(request.key, connection);

    poker.pushPlayer(player);

    connection.sendUTF(JSON.stringify({action: 'connect', data: player.id, total: player.total}));

    connection.on('message', (data) => {

        let message = JSON.parse(data.utf8Data);

        switch(message.action){

            case 'join':
                player.name = message.data;
                poker.broadcastPlayersList();
                break;
            case 'search_lobby':
                poker.broadcastLobbiesList();
                break;
            case 'onjoinlobby':
                poker.onJoinLobby(player, message.data);
                break;
            case 'onDeletelobby':
                poker.onDeleteLobby(message.data);
                break;
            case 'onLeaveLobby':
                poker.onLeaveLobby(player, message.data);
                break;
            case 'onEnterLobby':
                poker.broadcastPlayersInLobbiesList(message.data);
                break;
            case 'onGameBegin':
                poker.onGameBegin(message.data);
                break;
            case 'onEnterGame':
                poker.onEnterGame(message.data);
                break;
            case 'onLeaveGame':
                poker.onLeaveGame(player, message.data);
                break;
        }
    });

    connection.on("close", () => {
        poker.onClose(player);
    });
});