let canvas = document.getElementById("gameView");
let context = canvas.getContext("2d");
let canvasLeft = canvas.offsetLeft + canvas.clientLeft;
let canvasTop = canvas.offsetTop + canvas.clientTop;

canvas.width = (screen.height * .4) - 100;
canvas.height = canvas.width;


const newGameSubmit = document.getElementById("new-game");
const newLiveGameSubmit = document.getElementById("new-live-game");
const accessCodeInput = document.getElementById("accessCodeInput");
const getAccessCode = document.getElementById("getAccessCode");
const nextMoveSubmit = document.getElementById("next-move");
const statusSpan = document.getElementById("status");
const modal = document.getElementsByClassName("modal")[0];
const modalCloseBtn = document.getElementById("modalCloseButton");
modalCloseBtn.addEventListener("click", function(event) {
  modal.classList.add("hidden");
})

if (newGameSubmit !== null) {
  newGameSubmit.addEventListener('click', newGame);
}
if (newLiveGameSubmit !== null) {
  newLiveGameSubmit.addEventListener('click', newLiveGame);
}
if (nextMoveSubmit !== null) {
  nextMoveSubmit.addEventListener('click', nextMove);
}


if (getAccessCode !== null) {
  
  getAccessCode.addEventListener('click', findGame);
  getAccessCode.setAttribute('disabled', true);

  // Only trigger findGame on click when a full code is entered
  accessCodeInput.addEventListener('keyup', function(event) {
    if (this.value.length === 4) {
      getAccessCode.removeAttribute('disabled');
    } else {
      getAccessCode.setAttribute('disabled', true);
    }
  })
}

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

function findGame() {
  // get game from the api
  let spinner = showSpinner("canvas-window");
  let params = "?access_code=" + accessCodeInput.value + "&token=" + getTokenCookie()
  fetch("http://localhost:3000/api/live_games/" + params, {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json"
    }
  })
  .then(response => response.json())
  .then(function(json) {
    if (json.error === undefined){
      drawCodeWindow(json["access_code"], json["id"], json["game"]["white_name"], json["game"]["black_name"])
    }else{
      alert(json.error)
    }
    spinner.hide()
  })
  .catch(function(error){ 
    alert("Error: " + error)
  })
}

function newGame() {
  let spinner = showSpinner("canvas-window");

  const player1Name = document.getElementById("player1-name").value;
  const player2Name = document.getElementById("player2-name").value;

  let requestBody = {
    "game": {
      "white_name": player1Name,
      "black_name": player2Name
    }
  }

  fetch("http://localhost:3000/api/games", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json"
    },
    body: JSON.stringify(requestBody)
  })
  .then(response => response.json())
  .then(function(json) {
    if (json.error === undefined){
      setVars(json["game"])
      drawGame()
      drawMovePlay()
    }else{
      alert(json.error)
    }
    spinner.hide();
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
      drawMovePlay()
      
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
      drawMovePlay()
      
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
  drawMovePlay()
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
  fillPieces("white");
  fillPieces("black");

  function fillPieces(col) {
    pieces[col].forEach(function(el) {
      context.fillStyle = col;
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
      if (col === turn) {
        addFunctionOnClick(x, y, function() {
          selectPiece(el)
        });
      }
    })
  }
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
  
}

function drawMovePlay() {
  // TODO: allow this method to work with live games
  if (turnName !== "") {
    drawMoves();
    nextMoveSubmit.setAttribute("disabled", true)
  } else {
    nextMoveSubmit.removeAttribute("disabled")
  }
}

function drawCodeWindow(code, id, whiteName="", blackName="") {
  // TODO: just use white name and black name from params
  modal.classList.remove("hidden");
  let canv = document.getElementById("codeView");
  canv.width = (screen.height * .2) - 50;
  canv.height = canv.width / 2.0;


  function randColorVal() {
    return Math.floor(Math.random() * 255).toString(16);
  }

  let cx = canv.getContext("2d");
  cx.font = `48pt Algerian`;
  let r = randColorVal();
  let g = randColorVal();
  let b = randColorVal();
  cx.fillStyle = "#" + r + g + b;
  cx.fillText(code, 5, 50);

  let submit = document.getElementById("requestCodeButton")
  let whiteRadio = document.getElementById("whiteRadio");
  let whitePlayerInput = document.getElementById('whitePlayerInput')
  let blackRadio = document.getElementById("blackRadio");
  let blackPlayerInput = document.getElementById('blackPlayerInput')

  whiteRadio.checked = false;
  blackRadio.checked = false;
  whitePlayerInput.value = "";
  blackPlayerInput.value = "";

  let hasCookie = !!(getTokenCookie())

  if (hasCookie) {
    alert("Note: You can only be in one game at a time")
    whitePlayerInput.setAttribute("disabled", true)
    whiteRadio.setAttribute("disabled", true)
    blackPlayerInput.setAttribute("disabled", true)
    blackRadio.setAttribute("disabled", true)
    submit.setAttribute("disabled", true)
  }

  whitePlayerInput.addEventListener("keyup", function(event) {
    if (this.value.length === 0) {
      submit.setAttribute("disabled", true)
    } else {
      submit.removeAttribute("disabled")
    }
  })

  blackPlayerInput.addEventListener("keyup", function(event) {
    if (this.value.length === 0) {
      submit.setAttribute("disabled", true)
    } else {
      submit.removeAttribute("disabled")
    }
  })

  // Populate/disable player names already chosen
  if (whiteName !== "") {
    whitePlayerInput.value = whiteName
    whitePlayerInput.setAttribute("disabled", true)
    whiteRadio.setAttribute("disabled", true)
  }
  if (blackName !== "") {
    blackPlayerInput.value = blackName
    blackPlayerInput.setAttribute("disabled", true)
    blackRadio.setAttribute("disabled", true)
  }

  // disable entering for both teams
  if (blackName === "" && whiteName === "") {
    whiteRadio.addEventListener("change", function() {
      blackPlayerInput.setAttribute("disabled", true)
      whitePlayerInput.removeAttribute("disabled")
    })
    blackRadio.addEventListener("change", function() {
      // disable white player input text and enable black
      whitePlayerInput.setAttribute("disabled", true)
      blackPlayerInput.removeAttribute("disabled")
    })
  }
  if (blackName !== "" && whiteName !== "") {
    submit.setAttribute("disabled", true)
  }
  

  submit.addEventListener("click", function(event) {
    let playerName = null;
    let playerTeam = "";
    if (!whiteRadio.checked && !blackRadio.checked) {
      return null;
    } else {
      if (blackRadio.checked && blackPlayerInput !== "") {
        playerName = blackPlayerInput.value
        playerTeam = "black"
      } else if (whiteRadio.checked && whitePlayerInput !== "") {
        playerName = whitePlayerInput.value
        playerTeam = "white"
      }
      if (playerName !== null) {
        updateLiveGame(playerName, playerTeam, code, id)
      }
    }
  })

}

function newLiveGame() {

  let spinner = showSpinner("canvasCodeWindow");
  // Try the #create endpoint 
  fetch("http://localhost:3000/api/live_games", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json"
    }
  })
  .then(response => response.json())
  .then(function(json) {
    if (json.error === undefined){
      drawCodeWindow(json["access_code"], json["id"])
    }else{
      alert(json.error)
    }
    spinner.hide();
  })
  .catch(function(error){ 
    alert("Error: " + error)
  })
}

function getTokenCookie() {
  // let tokenIdFilled = document.getElementById("cookieholder").innerText !== ""
  // return (tokenIdFilled || cookieSaved)
  return document.cookie.split("; ").find((row) => row.startsWith("gametoken"))
}

function setTokenCookie(token) {
  document.cookie = 'gametoken=' + token + '; path=/'
  document.getElementById("cookieholder").innerText = token;
}

function updateLiveGame(playerName, playerTeam, code, id) {
  let spinner = showSpinner("canvasCodeWindow");
  let requestBody = {
    "player_name": playerName,
    "player_team": playerTeam,
    "access_code": code
  }
  fetch("http://localhost:3000/api/live_games/" + id , {
    method: "PATCH",
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json"
    },
    body: JSON.stringify(requestBody)
  })
  .then(response => response.json())
  .then(function(json) {
    if (json.error === undefined){
      // if both players ready, draw live game on current page,
      // await confirmation of first move
      if (json["is_ready"]) {
        modal.classList.add("hidden");
        alert("Game ready to begin")
        setVars(json["game"])
        drawGame()
        drawMovePlay()
      }

      else {
      // set token to allow future moves on the game
        if (json["token"] !== undefined) {

          // No cookie set
          if (!getTokenCookie()) {
            setTokenCookie(json["token"])
          }
          // newUrl = "http://localhost:3000/api/live_games/" + json["id"]
          // fetch(newUrl, {
          //   method: "GET",
          //   headers: {
          //     "Content-Type": "application/json",
          //     "Accept": "application/json"
          //   }
          // }).then(response => response.json())
          // .then(function(json) {
          //   if (json.error === undefined) {
          //     // show game status
          //   }
          // })
        }
        drawCodeWindow(json["access_code"], json["id"])
      }
    } else {
      alert(json.error)
    }
    spinner.hide();
  })
  .catch(function(error){ 
    alert("Error: " + error)
  })
}

function showSpinner(canvasParentId) {
  let spinner = document.createElement('div');
  spinner.id = "loading";
  spinner.innerHTML = '<div id="loadingspinner"><img src="spinner2.gif"></div>';
  document.getElementById(canvasParentId).appendChild(spinner);

  // Add hide function for spinner
  spinner.hide = function() {
    this.classList.add("hidden");
  }

  return spinner
}