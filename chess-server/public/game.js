let canvas = document.getElementById("game-view");
let context = canvas.getContext("2d");
let canvasLeft = canvas.offsetLeft + canvas.clientLeft;
let canvasTop = canvas.offsetTop + canvas.clientTop;

canvas.width = (screen.height * .4) - 100;
canvas.height = canvas.width;


const newGameSubmit = document.getElementById("new-game");
const newLiveGameSubmit = document.getElementById("new-live-game");
const accessCodeInput = document.getElementById("access-code-input");
const getAccessCode = document.getElementById("get-access-code");
const nextMoveSubmit = document.getElementById("next-move");
const statusSpan = document.getElementById("status");
const modal = document.getElementsByClassName("modal")[0];
const modalCloseBtn = document.getElementById("modal-close-button");
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
  let tokenCookie = getTokenCookie()
  if (!!tokenCookie) {
    tokenCookie = tokenCookie.split("gametoken=")[1]
  }
  let params = "?access_code=" + accessCodeInput.value + "&token=" + tokenCookie

  fetchFromApi("/api/live_games/" + params, "GET", null, function(json) {
    drawCodeWindow(json)
  })
}

function newGame() {
  let requestBody = {
    "game": {
      "white_name": document.getElementById("player1-name").value,
      "black_name": document.getElementById("player2-name").value
    }
  }

  fetchFromApi("/api/games", "POST", requestBody, function(json) {
    setVars(json["game"])
    drawGame()
    drawMovePlay()
  })
}

function nextMove() {
  fetchFromApi("/api/games/" + gameId, "PATCH", null, function(json) {
    setVars(json)
    drawGame()
    drawMovePlay()
  })
}

function selectMove(move) {

  fetchFromApi("/api/games/", "PATCH", { "move": move }, function(json) {
    setVars(json)
    drawGame()
    drawMovePlay()
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
function fillPieces(thisCol, team=null) {
  pieces[thisCol].forEach(function(el) {
    context.fillStyle = thisCol;
    let x, y;
    if (team !== null) {

      if (team === "white") {
        x = fileIndexOf(el.position[0]) * squareSize;
        y = (7 - rankIndexOf(el.position[1])) * squareSize;
      } else {
        x = (7 - fileIndexOf(el.position[0])) * squareSize;
        y = rankIndexOf(el.position[1]) * squareSize;
      }
      context.fillText(el.char, x + tinySize, y + smallSize);
      // Add click handler
      if (thisCol === team) {
        addFunctionOnClick(x, y, function() {
          selectPiece(el)
        });
      }

    } else {
      if (turn === "white" || turnName === "") {
        x = fileIndexOf(el.position[0]) * squareSize;
        y = (7 - rankIndexOf(el.position[1])) * squareSize;
      } else {
        x = (7 - fileIndexOf(el.position[0])) * squareSize;
        y = rankIndexOf(el.position[1]) * squareSize;
      }
      context.fillText(el.char, x + tinySize, y + smallSize);
      // Add click handler
      if (thisCol === turn) {
        addFunctionOnClick(x, y, function() {
          selectPiece(el)
        });
      }

    }
  })
}

function drawPieces(team=null){
  context.font = `50px Verdana`;
  fillPieces("white", team);
  fillPieces("black", team);
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

  let showTeam = getTokenColor();

  drawBoard();
  drawPieces(showTeam);
  
}

function drawMovePlay() {
  // TODO: allow this method to work with live games
  let isNotComputer = (turnName !== "");
  if (isNotComputer && json["turn"] === getTokenColor()) {
    drawMoves();
    nextMoveSubmit.setAttribute("disabled", true)
  } else {
    nextMoveSubmit.removeAttribute("disabled")
  }
}

// This background modal displays the status of a "live game"
// which includes which players have joined. This method depends on a
// successful response (json) from either #show or #update on /api/live_games

function drawCodeWindow(json) {
  modal.classList.remove("hidden");
  let canv = document.getElementById("code-view");
  canv.width = (screen.height * .2) - 50;
  canv.height = canv.width / 2.0;
  
  let whiteName = "";
  let blackName = "";
  if (json["game"]) {
    whiteName = json["game"]["white_name"]
    blackName = json["game"]["black_name"]
  }

  function randColorVal() {
    return Math.floor(Math.random() * 255).toString(16);
  }

  let cx = canv.getContext("2d");
  cx.font = `48pt Comic Sans MS`;
  let r = randColorVal();
  let g = randColorVal();
  let b = randColorVal();
  cx.fillStyle = "#" + r + g + b;
  cx.fillText(json["access_code"], 5, 80);

  let submit = document.getElementById("request-code-button")
  let whiteRadio = document.getElementById("white-radio");
  let whitePlayerInput = document.getElementById('white-player-input')
  let blackRadio = document.getElementById("black-radio");
  let blackPlayerInput = document.getElementById('black-player-input')

  whiteRadio.checked = false;
  blackRadio.checked = false;
  whitePlayerInput.value = "";
  blackPlayerInput.value = "";

  let tokenCookie = getTokenCookie()

  if (!!tokenCookie) {
    if (json["is_ready"] && json["token"] ) {
      // Close out and show live game
      debugger
      modal.classList.add("hidden")
      setVars(json["game"])
      drawGame()
      drawMovePlay()
      return null;

    } else  {
      whitePlayerInput.setAttribute("disabled", true)
      whiteRadio.setAttribute("disabled", true)
      blackPlayerInput.setAttribute("disabled", true)
      blackRadio.setAttribute("disabled", true)
      submit.setAttribute("disabled", true)
    }
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
        updateLiveGame(playerName, playerTeam, json)
      }
    }
  })

}

function newLiveGame() {
  fetchFromApi("/api/live_games", "POST", null, function(json) {
    drawCodeWindow(json)
  })
}

function getTokenColor() {

  let cookie = document.cookie.split("; ").find((row) => row.startsWith("color"));
  return (cookie || document.getElementById("cookieholder-color").innerText);
}

function getTokenCookie() {
  // let tokenIdFilled = document.getElementById("cookieholder").innerText !== ""
  // return (tokenIdFilled || cookieSaved)
  return document.cookie.split("; ").find((row) => row.startsWith("gametoken"))
}

function setTokenCookie(token, color=null) {
  document.cookie = 'gametoken=' + token + '; path=/'
  document.cookie = 'color=' + color + '; path=/'
  document.getElementById("cookieholder").innerText = token;
  document.getElementById("cookieholder-color").innerText = color;
}

function updateLiveGame(playerName, playerTeam, prevJson) {
  let code = prevJson["access_code"];
  let id = prevJson["id"];
  let requestBody = {
    "player_name": playerName,
    "player_team": playerTeam,
    "access_code": code
  }
  fetchFromApi("/api/live_games/" + id, "PATCH", requestBody, function(json) {
    if (json["is_ready"] ) {
      // No validation needed because response function is executed
      // by the client who joined the game and who is issued a token
      modal.classList.add("hidden");
      alert("Game ready to begin")
      setTokenCookie(json["token"], json["color"])
      setVars(json["game"])
      drawGame()
      drawMovePlay()
    }

    else {
    // set token to allow future moves on the game
      if (json["token"] !== undefined) {

        // No cookie set
        if (!getTokenCookie()) {
          setTokenCookie(json["token"], json["color"])
        }
      }
      json["access_code"] = prevJson["access_code"]
      drawCodeWindow(json)
    }
  })
}

function fetchFromApi(endpoint, method, params=null, successCallback=null) {
  let spinner = showSpinner("canvas-code-window");
  let apiUrl = "http://localhost:3000" + endpoint;
  let requestObj = {
    method: method,
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json"
    }
  }
  if (params !== null) {
    requestObj.body = JSON.stringify(params);
  }

  fetch(apiUrl, requestObj)
  .then(response => response.json())
  .then(function(json) {
    if (json.errors === undefined && json.error === undefined){

      if (successCallback !== null) {
        successCallback(json);
      }

    } else {
      alert("Error:" + json.error + " " + json.errors)
    }
    spinner.hide()
  })
  .catch(function(error) {
    alert("Error: " + error)
  })
}

function showSpinner(canvasParentId) {
  let spinner = document.createElement('div');
  spinner.id = "loading";
  spinner.innerHTML = '<div id="loading-spinner"><img src="spinner2.gif"></div>';
  document.getElementById(canvasParentId).appendChild(spinner);

  // Add hide function for spinner
  spinner.hide = function() {
    this.classList.add("hidden");
  }

  return spinner
}