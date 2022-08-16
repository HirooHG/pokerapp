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
        this.index = undefined;
        this.indexInLobby = undefined;
        this.indexLobby = undefined;
        this.cards = undefined;
        this.total = 0;
    }
    getId(){
        return {name: this.name, id: this.id, total: this.total};
    }
}
class Lobby{
    constructor() {
        this.players = [];
        this.index = undefined;
    }
    getJson(){
        return {index: this.index, numberOfPlayer: this.players.length};
    }
}
class Poker{
    constructor() {
        this.players = [];
        this.lobbies = [];
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
        let lobby = this.lobbies.at(Number(index));
        lobby.players.forEach((player) => {
            player.connection.sendUTF(JSON.stringify({"action" : "onGameBegin", "data" : ""}));
        });

        //Set all cards and other things
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

        this.lobbies.forEach((lobby, index, array) => {
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
        //onPlayerListInLobby

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
                var message = JSON.stringify({
                    action: "onIndexChanged",
                    data: index
                });
                player.connection.sendUTF(message);
            });
        });
    }
    handOutCards(){

    }
}

const poker = new Poker();

wsServer.on('request', function(request) {

    let connection = request.accept(null, request.origin);
    let player = new Player(request.key, connection);

    poker.pushPlayer(player);

    connection.sendUTF(JSON.stringify({action: 'connect', data: player.id}));

    connection.on('message', function(data) {

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
        }
    });

    connection.on("close", function(){
        poker.onClose(player);
    });
});