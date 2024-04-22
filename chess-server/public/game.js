let canvas = document.getElementById("gameView");

canvas.width = (screen.height * .5) * .75 - 100;
canvas.height = canvas.width;


const newGameSubmit = document.getElementById("new-game");
const player1Name = document.getElementById("player1-name").value;
const player2Name = document.getElementById("player2-name").value;
newGameSubmit.addEventListener('click', newGame);

function newGame() {

  let card = document.createElement('div');
  card.id = "loading";
  card.innerHTML = '<div id="loadingspinner"><img src="spinner.gif"></div>';
  document.getElementById("canvas-window").appendChild(card);

  fetch("http://localhost:3000/api/games", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json"
    },
    body: JSON.stringify({
      "game": {
        "white_name": player1Name,
        "black_name": player2Name
      }
    })
  })
  .then(response => response.json())
  .then(function(json) {
    if (json.error === undefined){
      drawGame(json)
    }else{
      alert(json.error)
    }
    card.classList.add("hidden");
  })
  .catch(function(error){ 
    alert("Please ensure the chess development server is running locally.")
  })
}

function drawGame(json) {

  let ctx = canvas.getContext("2d");
  ctx.strokeText(json["pieces"],50,50)

}
