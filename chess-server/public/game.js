let canvas = document.getElementById("gameView");

canvas.width = (screen.height * .4) - 100;
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

  let context = canvas.getContext("2d");
  let pieces = JSON.parse(json["pieces"]);

  var length = canvas.width;
  var squareSize = canvas.width / 8.0;
  var halfSize = squareSize / 2.0;

  var colorW = "#97aaac";
  var colorB = "#556567";
  var squareColor = colorB;
  switchSquareColor = function() {
    squareColor = (squareColor === colorW ? colorB : colorW);
    return squareColor
  }

  function fileIndexOf(letter) {
    return "abcdefgh".indexOf(letter);
  }
  function rankIndexOf(num) {
    return "12345678".indexOf(num);
  }


  function drawBoard(){
      for (let x = 0; x <= length; x += squareSize) {
        for (let y = 0; y <= length; y += squareSize) {
            context.fillStyle = switchSquareColor();
            context.fillRect(x, y, squareSize, squareSize);
        }
      }
  }

  function drawPieces(pieces){
    context.font = `40px Verdana`;
      pieces["black"].forEach(function(el) {
        context.fillStyle = "black";
        let x = fileIndexOf(el.position[0]) * squareSize;
        let y = rankIndexOf(el.position[1]) * squareSize;
        context.fillText(el.char, x + halfSize, y + halfSize);
      })
      pieces["white"].forEach(function(el) {
        context.fillStyle = "white";
        let x = fileIndexOf(el.position[0]) * squareSize;
        let y = rankIndexOf(el.position[1]) * squareSize;
        context.fillText(el.char, x + halfSize, y + halfSize);
      })
  }

  drawBoard();
  drawPieces(pieces);
}
