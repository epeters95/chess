let canvas = document.getElementById("gameView");
let context = canvas.getContext("2d");
let canvasLeft = canvas.offsetLeft + canvas.clientLeft;
let canvasTop = canvas.offsetTop + canvas.clientTop;

canvas.width = (screen.height * .4) - 100;
canvas.height = canvas.width;


const newGameSubmit = document.getElementById("new-game");
const nextMoveSubmit = document.getElementById("next-move");
const statusSpan = document.getElementById("status");
newGameSubmit.addEventListener('click', newGame);

nextMoveSubmit.addEventListener('click', nextMove);

var gameId = 0;
var turn;
var turnName;
var status = "";
var pieces = {};

var selectedPiece= "";
var selectedMoves = [];

var length = canvas.width;
var squareSize = canvas.width / 8.0;
var smallSize = squareSize * 0.9;
var tinySize = squareSize * 0.1;

var colorW = "#97aaac";
var colorB = "#556567";
var squareColor = colorB;
var switchSquareColor = function() {
  squareColor = (squareColor === colorW ? colorB : colorW);
  return squareColor
}
var eventListeners = [];

function newGame() {

  let spinner = document.createElement('div');
  spinner.id = "loading";
  spinner.innerHTML = '<div id="loadingspinner"><img src="spinner.gif"></div>';
  document.getElementById("canvas-window").appendChild(spinner);

  const player1Name = document.getElementById("player1-name").value;
  const player2Name = document.getElementById("player2-name").value;

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
      setVars(json)
      drawGame()
    }else{
      alert(json.error)
    }
    spinner.classList.add("hidden");
  })
  .catch(function(error){ 
    alert("Error: " + error)
  })
}

function nextMove() {
  fetch("http://localhost:3000/api/games/" + gameId, {
    method: "PATCH",
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json"
    }
  })
  .then(response => response.json())
  .then(function(json) {
    if (json.error === undefined){
      setVars(json)
      drawGame()
      
    }else{
      alert(json.error)
    }
  })
  .catch(function(error){ 
    alert("Error: " + error)
  })
}

function selectMove(move) {
  fetch("http://localhost:3000/api/games/" + gameId, {
    method: "PATCH",
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json"
    },
    body: JSON.stringify({ "move": move })
  })
  .then(response => response.json())
  .then(function(json) {
    if (json.error === undefined){
      setVars(json)
      drawGame()
      
    }else{
      alert(json.error)
    }
  })
  .catch(function(error){ 
    alert("Error: " + error)
  })
}

function selectPiece(piece) {
  if (selectedPiece === "") {
    selectedPiece = piece
    selectedMoves = moves.filter(function(move) {
      let pc = JSON.parse(move.piece_str)
      return pc.position === selectedPiece.position
    })
  }
  else {
    selectedPiece = "";
    selectedMoves = [];
  }
  drawGame()
}


function setVars(json) {
  gameId =   json["id"];
  status =   json["status_str"];
  turn =     json["turn"];
  turnName = json["turn_name"];
  pieces =   JSON.parse(json["pieces"]);
  moves =    json["legal_moves"];
  selectedMoves = [];
  selectedPiece = "";
}

function addFunctionOnClick(x, y, func) {
  let myFunc = function(event) {
    let eventX = event.offsetX;
    let eventY = event.offsetY;

    if (eventY > y && eventY < y + squareSize 
        && eventX > x && eventX < x + squareSize) {
        func();
    }
  }
  canvas.addEventListener('click', myFunc);
  eventListeners.push(myFunc);
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

function drawPieces(){
  context.font = `50px Verdana`;
  ["black", "white"].forEach(function(color) {
    pieces[color].forEach(function(el) {
      context.fillStyle = color;
      let x, y;
      if (turn === "white" || turnName === "") {
        x = fileIndexOf(el.position[0]) * squareSize;
        y = (7 - rankIndexOf(el.position[1])) * squareSize;
      } else {
        x = (7 - fileIndexOf(el.position[0])) * squareSize;
        y = rankIndexOf(el.position[1]) * squareSize;
      }
      context.fillText(el.char, x + tinySize, y + smallSize);
      // Add click handler
      if (color === turn) {
        addFunctionOnClick(x, y, function() {
          selectPiece(el);
        });
      }
    })
  })
}

function drawMoves() {
  selectedMoves.forEach(function(move) {
    let x, y;
    if (turn === "white") {
      x = fileIndexOf(move.new_position[0]) * squareSize;
      y = (7 - rankIndexOf(move.new_position[1])) * squareSize;
    } else {
      x = (7 - fileIndexOf(move.new_position[0])) * squareSize;
      y = rankIndexOf(move.new_position[1]) * squareSize;
    }
    let halfSquare = squareSize / 2.0;
    let bgColor = ( (fileIndexOf(move.new_position[0]) + rankIndexOf(move.new_position[1])) % 2 === 1) ? colorB : colorW;
    const grd = context.createRadialGradient(
      x + halfSquare,
      y + halfSquare,
      0,
      x + halfSquare,
      y + halfSquare,
      tinySize
      );

    grd.addColorStop(0, turn);
    grd.addColorStop(1, bgColor);
    // Draw a filled Rectangle
    context.fillStyle = grd;
    context.fillRect(
      x,
      y,
      squareSize,
      squareSize
      );

    // Add click handler
    addFunctionOnClick(x, y, function() {
      selectMove(move);
    });
  })
}


function drawGame() {

  statusSpan.innerText = status;

  context.clearRect(0, 0, canvas.width, canvas.height);
  eventListeners.forEach(function(el) {
    canvas.removeEventListener('click', el);
  })

  switchSquareColor()

  drawBoard();
  drawPieces();
  if (turnName !== "") {
    drawMoves();
    nextMoveSubmit.setAttribute("disabled", true)
  } else {
    nextMoveSubmit.removeAttribute("disabled")
  }
}
