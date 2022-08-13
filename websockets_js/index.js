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
        this.name = "player";

        this.index = undefined;
        this.indexInLobby = undefined;
        this.indexLobby = undefined;
    }
    getId(){
        return {name: this.name, id: this.id};
    }
}
class Lobby{
    constructor() {
        this.players = [];

        this.index = undefined;
    }
    getJson(){
        return {index: this.index, nbOfPlayer: this.players.length};
    }
}
class Poker{
    constructor(request) {

        this.players = [];
        this.lobbies = [];
    }

    pushPlayer(player){
        player.index = this.players.length;
        this.players.push(player);
        this.replaceIndexesPlayers();
    }
    popPlayer(player){
        this.players.splice(player.index ,1);
        this.replaceIndexesPlayers()
    }

    pushLobby(lobby){
        this.lobbies.push(lobby);
        this.replaceIndexesLobbies();
    }
    popLobby(lobby){
        this.lobbies.splice(lobby.index,1);
        this.replaceIndexesLobbies();
    }

    pushPlayerInLobby(lobby, player){
        lobby.players.push(player);
        this.replaceIndexesPlayersInLobbies();
    }
    popPlayerInLobby(lobby, player){
        lobby.players.splice(player.indexInLobby, 1);
        this.replaceIndexesPlayersInLobbies();
    }

    onClose(player){
        this.popPlayer(player);
        this.lobbies.forEach(function(lobby){
            lobby.players.forEach(function(player1){
                if(player.id === player1.id) lobby.popPlayer(player);
            });
        });
        this.replaceIndexesPlayers();

        this.broadcastPlayersList();
        this.broadcastLobbiesList();
    }
    onJoinLobby(player){
        if(!this.lobbies.some((lobby) => lobby.players.some((playerIn) => playerIn.id === player.id))){
            let lobby = new Lobby();

            lobby.index = this.lobbies.length;
            this.lobbies.push(lobby);

            this.broadcastLobbiesList();

            let message = JSON.stringify({
                'action': 'joinlobby',
                'data': lobby.index
            });
            player.connection.sendUTF(message);
        }
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

        /*this.lobbies.forEach(function(lobby, index) {
            if(lobby.players.length === 0){
                this.lobbies.splice(index, 1);
            }
        })
        this.replaceIndexesLobbies();
        * */

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
        this.lobbies.forEach(function (lobby, index){
            lobby.players.forEach(function(player, index){
               player.index = index;
            });
        });
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
                poker.onJoinLobby(player);
                break;
        }
    });

    connection.on("close", function(){
        poker.onClose();
    });
});