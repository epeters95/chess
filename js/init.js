const newGameSubmit     = document.getElementById("new-game");
const player1Name       = document.getElementById("player1-name");
const player2Name       = document.getElementById("player2-name");
const newLiveGameSubmit = document.getElementById("new-live-game");
const accessCodeInput   = document.getElementById("access-code-input");
const getAccessCode     = document.getElementById("get-access-code");
const requestCodeSubmit = document.getElementById("request-code-button");
var submitEventListeners = [];
var disableGameReadyLoop = false;

const modal = document.getElementsByClassName("modal")[0];
const modalCloseBtn = document.getElementById("modal-close-button");
modalCloseBtn.addEventListener("click", function() {
  modal.classList.add("hidden");
  disableGameReadyLoop = true;
})

const promotionPopup = document.getElementById("promotion-popup");
const promotionSubmit = document.getElementById("promotion-submit");
promotionSubmit.addEventListener("click", function() {
  promotionPopup.classList.add("hidden")
})


if (newGameSubmit !== null) {

  const checkNamesNotBlank = function() {
    if (player1Name.value.length === 0 && player2Name.value.length === 0) {
      newGameSubmit.setAttribute('disabled', true);
    } else {
      newGameSubmit.removeAttribute('disabled');
    }
  }
  checkNamesNotBlank();
  player1Name.addEventListener('keyup', checkNamesNotBlank);
  player2Name.addEventListener('keyup', checkNamesNotBlank);
  newGameSubmit.addEventListener('click', newGame);
}
if (newLiveGameSubmit !== null) {
  newLiveGameSubmit.addEventListener('click', newLiveGame);
}


if (getAccessCode !== null) {
  
  getAccessCode.addEventListener('click', findGame);
  if (accessCodeInput.value.length !== 4) {
    getAccessCode.setAttribute('disabled', true);
  }

  // Only trigger findGame on click when a full code is entered
  accessCodeInput.addEventListener('keyup', function() {
    if (this.value.length === 4) {
      getAccessCode.removeAttribute('disabled');
    } else {
      getAccessCode.setAttribute('disabled', true);
    }
  })
}

var gameView = null;

const domElements = {
  "statusSpan": statusSpan,
  "promotionPopup": promotionPopup,
  "promotionSubmit": promotionSubmit
}

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
      "white_name": player1Name.value,
      "black_name": player2Name.value
    }
  }

  let computerTeam = null;
  if (player1Name.value === "") {
    computerTeam = "white"
  } else if (player2Name.value === "") {
    computerTeam = "black"
  }

  fetchFromApi("/api/games", "POST", requestBody, function(json) {
    hideQuote();
    gameView = new GameView(canvas, json, domElements, false, computerTeam)
    gameView.draw()
    // Initiate first move if computer is white
    if (computerTeam === "white") {
      gameView.nextComputerMove()
    }
  })
}

function drawCodeWindow(json) {
  disableGameReadyLoop = false;
  modal.classList.remove("hidden");
  let canv = document.getElementById("code-view");
  canv.width = 238;
  canv.height = 119;
  
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

  
  let whiteRadio = document.getElementById("white-radio");
  let whitePlayerInput = document.getElementById('white-player-input')
  let blackRadio = document.getElementById("black-radio");
  let blackPlayerInput = document.getElementById('black-player-input')

  whiteRadio.checked = false;
  blackRadio.checked = false;
  whitePlayerInput.value = "";
  blackPlayerInput.value = "";

  let tokenCookie = getTokenCookie()

  if (tokenCookie && tokenCookie !== '') {
    if (json["is_ready"] && json["token"] ) {
      // Close out and show live game
      modal.classList.add("hidden")
      hideQuote();

      if (gameView === null) {
        gameView = new GameView(canvas, json, domElements, true)
      }
      gameView.draw()
      return null;

    } else  {
      whitePlayerInput.setAttribute("disabled", true)
      whiteRadio.setAttribute("disabled", true)
      blackPlayerInput.setAttribute("disabled", true)
      blackRadio.setAttribute("disabled", true)
      requestCodeSubmit.setAttribute("disabled", true)
    }
  }

  whitePlayerInput.addEventListener("keyup", function() {
    if (this.value.length === 0) {
      requestCodeSubmit.setAttribute("disabled", true)
    } else {
      requestCodeSubmit.removeAttribute("disabled")
    }
  })

  blackPlayerInput.addEventListener("keyup", function() {
    if (this.value.length === 0) {
      requestCodeSubmit.setAttribute("disabled", true)
    } else {
      requestCodeSubmit.removeAttribute("disabled")
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
    requestCodeSubmit.setAttribute("disabled", true)
  }
  
  const submitEvent = function() {
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
  }
  submitEventListeners.forEach((el) => {
    requestCodeSubmit.removeEventListener("click", el)
  })
  submitEventListeners = [];
  submitEventListeners.push(submitEvent);
  requestCodeSubmit.addEventListener("click", submitEvent);

}

function newLiveGame() {
  fetchFromApi("/api/live_games", "POST", null, function(json) {
    setTokenCookie('')
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
      quoteSpan.classList.add("hidden");
      alert("Game ready to begin")
      setTokenCookie(json["token"], json["color"], json["access_code"])

      if (gameView === null) {
        gameView = new GameView(canvas, json, domElements, true)
      }
      gameView.draw()
    }

    else {
    // set token to allow future moves on the game
      if (json["token"] !== undefined) {
          setTokenCookie(json["token"], json["color"], json["access_code"])
      }
      json["access_code"] = prevJson["access_code"]
      drawCodeWindow(json)

      // Refresh until opponent joins the game
      checkGameReadyLoop(id, json["access_code"])
    }
  })
}

function checkGameReadyLoop(id, accessCode) {
  setTimeout(function() {

    let params = "?access_code=" + accessCode
    fetchFromApi("/api/live_games/" + id + params, "GET", null, function(json) {
      if (!json["is_ready"]) {
        if (!disableGameReadyLoop) {
          checkGameReadyLoop(id, accessCode)
        }
      } else {
        modal.classList.add("hidden");
        quoteSpan.classList.add("hidden");
        alert("Game ready to begin")
        if (gameView === null) {
          gameView = new GameView(canvas, json, domElements, true)
        }
        gameView.draw()
      }
    })

  }, 10000)
}