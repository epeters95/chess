const newGameSubmit = document.getElementById("new-game");
const newLiveGameSubmit = document.getElementById("new-live-game");
const accessCodeInput = document.getElementById("access-code-input");
const getAccessCode = document.getElementById("get-access-code");
const nextMoveSubmit = document.getElementById("next-move");

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
  if (accessCodeInput.value.length !== 4) {
    getAccessCode.setAttribute('disabled', true);
  }

  // Only trigger findGame on click when a full code is entered
  accessCodeInput.addEventListener('keyup', function(event) {
    if (this.value.length === 4) {
      getAccessCode.removeAttribute('disabled');
    } else {
      getAccessCode.setAttribute('disabled', true);
    }
  })
}

var gameView = null;

const quoteWrapper = document.getElementById("quote-wrapper");
const quoteSpan = document.createElement("span")
quoteSpan.classList.add("quote-span");

fetchFromApi("/api/quote", "GET", null, function(json) {
  quoteSpan.innerText = json["quote"];
  quoteWrapper.appendChild(quoteSpan);
})

function refreshGame() {
  gameView.refresh()
}

function findGame() {
  // get game from the api
  let tokenCookie = getTokenCookie()
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

    let quoteSpan = document.getElementsByClassName("quote-span")[0]
    if (quoteSpan !== undefined) {
      quoteSpan.classList.add("hidden")
    }

    gameView = new GameView(canvas, json, statusSpan, false, nextMoveSubmit)
    gameView.draw()
  })
}

function nextMove() {
  gameView.nextComputerMove()
}

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
      modal.classList.add("hidden")
      let quoteSpan = document.getElementsByClassName("quote-span")[0]
      if (quoteSpan !== undefined) {
        quoteSpan.classList.add("hidden")
      }

      if (gameView === null) {
        gameView = new GameView(canvas, json, statusSpan, true)
      }
      gameView.draw()
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
      setTokenCookie(json["token"], json["color"], json["access_code"])

      if (gameView === null) {
        gameView = new GameView(canvas, json, statusSpan, true)
      }
      gameView.draw()
    }

    else {
    // set token to allow future moves on the game
      if (json["token"] !== undefined) {

        // No cookie set
        if (!getTokenCookie()) {
          setTokenCookie(json["token"], json["color"], json["access_code"])
        }
      }
      json["access_code"] = prevJson["access_code"]
      drawCodeWindow(json)
    }
  })
}