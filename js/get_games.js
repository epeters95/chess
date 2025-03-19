let table = document.getElementById("game-table");

var windowKeyEventListeners = [];

let modalGames = document.getElementsByClassName("modal")[0];
let modalCloseBtnGames = document.getElementById("modal-close-button");
modalCloseBtnGames.addEventListener("click", function() {
  modalGames.classList.add("hidden");
  if (windowKeyEventListeners.length > 0) {
    window.removeEventListener("keydown", windowKeyEventListeners.pop())
  }
  let evalBtn = document.getElementById("load-eval-btn")
  if (evalBtn) {
    evalBtn.remove();
    let evalDiv = document.getElementById("load-eval")
    evalDiv.classList.add("hidden")
  }
  let evalCont = document.getElementById("eval-container")
  if (evalCont) {
    evalCont.classList.add("hidden")
    let whiteBar = document.getElementById("eval-white")
    whiteBar.classList.add("hidden")
    let blackBar = document.getElementById("eval-black")
    blackBar.classList.add("hidden")
  }
})

let searchQuery = document.getElementById("search-query");
let searchButton = document.getElementById("search-button");

searchButton.addEventListener("click", function() {
  window.location.search = searchQuery.value;
})

let movesList = document.getElementById("moves-list");
let gameTitle = document.getElementById("game-title");
var gameView = null;

var currentMoveIndex = 0;

// Initialize map variable
var moveToPiecesMap = {};
var moveToEvalMap = {};

function getGames() {

  fetchFromApi("/api/games" + window.location.search, "GET", null, function(json) {
    populateTable(json)
  })

}

function populateTable(json) {
  let htmlString = "";
  let gamesArray = json["games"];
  let maxRows = Math.ceil(gamesArray.length / 3.0);

  // 3-column grid of games
  for (let j = 0; j < maxRows; j++) {

    if (gamesArray.length > 0) {
      htmlString += "<tr>";

      for (let i = 0; i < 3; i++) {

        if (gamesArray.length > 0) {
          let game = gamesArray.shift();
          let view = gameViewHtml(game);
          htmlString += "<td>" + view + "</td>";
        }
      }
      htmlString += "</tr>";
    }
  }
  table.innerHTML = htmlString;

  Array.from(document.getElementsByClassName("get-board")).forEach(function(el) {
    let id = el.getAttribute("data-id");
    let boardUrl = "/api/games/" + id + "/board"
    boardUrl += "?with_history=true"

    let imgKey = "thumbnail-" + id;

    // Check for either local or server cached image
    let cachedImg = window.localStorage.getItem(imgKey);
    let thumbnailDrawn = drawGameThumbnail(el.parentElement, cachedImg);
    
    if (!thumbnailDrawn) {

      // Get game thumbnail
      fetchFromApi(boardUrl, "GET", null, function(json) {
        let tempCanvas = document.createElement("canvas")
        tempCanvas.width = 476;
        tempCanvas.height = 476;
        tempCanvas.classList.add("hidden")

        // iterate moves to middlegame
        let halfway = Math.floor(json["moves"].length / 2) + 1
        json["game"]["pieces"] = json["pieces_history"][halfway]

        gameView = new GameView(tempCanvas, json, {"statusSpan": statusSpan}, false)
        gameView.draw(false, function() {

          // Draw thumbnail
          let canvasImg = tempCanvas.toDataURL();
          drawGameThumbnail(el.parentElement, canvasImg);
          window.localStorage.setItem(imgKey, canvasImg)

          // Send to server
          let body = {"game_id": id, "img_str": canvasImg}
          fetchFromApi("/api/thumbnail", "POST", body, function(json) {
            console.log("Returned img thumbnail to server")
          })
        })
      })
    }
    el.addEventListener("click", function() {

      fetchFromApi(boardUrl, "GET", null, function(json) {
        populateGameAndMoves(json, id);
      })

    })
  });
}

function drawGameThumbnail(imgDiv, dataStr) {

  if (imgDiv.style.backgroundImage) {
    return true;

  } else if (dataStr) {
    imgDiv.style.backgroundImage = "url(" + dataStr + ")"
    imgDiv.style.backgroundSize = "contain";
    imgDiv.style.backgroundBlendMode = "overlay";
    return true;
  }
  return false;
}

function populateGameAndMoves(json, gameId) {
  // Fill in title
  if (gameTitle) {
    gameTitle.innerHTML = getGameTitle(json["game"])
  }
  // Populate snapshots of the game at each move
  let evaluated = true;
  moveToPiecesMap = {};
  moveToEvalMap = {};
  json["moves"].forEach(function(move, i) {

    moveToPiecesMap[i] = json["pieces_history"][i];
    
    // Note: Because json["moves"] includes an initial null,
    // its indexes mapped to moveToEvalMap are adjusted by -1
    if (move) {
      if (move.evaluation === null || move.evaluation === undefined) {
        evaluated = false;
      } else {
        moveToEvalMap[i - 1] = move.evaluation 
      }
    }
  })
  currentMoveIndex = 0;

  // Initiate an eval load on board#update
  if (!evaluated) {
    let boardUrl = "/api/boards/" + gameId
    let evalDiv = document.getElementById("load-eval")
    evalDiv.classList.remove("hidden")

    let evalButton = document.createElement("button")
    evalButton.classList.add("eval-btn")
    evalButton.setAttribute("id", "load-eval-btn")
    evalButton.innerHTML = "Load Eval"
    
    evalButton.addEventListener("click", () => {

      fetchFromApi(boardUrl, "PATCH", null, function(evalJson) {
        
        if (evalJson.status === "ok") {
          evalDiv.classList.add("hidden")
          evalJson.move_evals.forEach((el, idx) => {
            moveToEvalMap[idx] = el
          })
          showBoardRefresh(json, null, moveToEvalMap[json["moves"].length - 2])
        }
      })
      evalButton.setAttribute("disabled", true)
    })

    evalDiv.appendChild(evalButton)

  }
  showBoardRefresh(json, null, moveToEvalMap[json["moves"].length - 2])
}

function showBoardRefresh(json, selectedId, showEval=false) {
  modalGames.classList.remove("hidden");
  gameView = new GameView(canvas, json, {"statusSpan": statusSpan}, false)

  new Promise((resolve) => {
    gameView.draw()
    resolve()

  }).then(() => {
    // Populate moves sidebar
    drawMoveList(json, selectedId, showEval)
  })
  
}

function drawMoveList(json, selectedId, showEval) {
  movesList.innerHTML = "";
  let list = document.createElement("table");
  let row;

  if (json["moves"].length === 0) {
    let span = document.createElement("span");
    span.innerHTML = "No moves played";
    movesList.appendChild(span);
    return;
  } else {
    const keydownListener = function(e) {
      let len = json["moves"].length
      let code = e.keyCode;
      let redraw = false;
      
      if (code == '38' || code == '37') {       // up, or left
        if (currentMoveIndex > 1) {
          currentMoveIndex -= 1;
          redraw = true;
        }
      }
      else if (code == '40' || code == '39' || code == '13' ) {  // down, or right or enter
        if (currentMoveIndex < len - 1) {
          currentMoveIndex += 1;
          redraw = true;
        }
      }
      if (redraw) {
        json["game"]["pieces"] = moveToPiecesMap[currentMoveIndex];

        // Because json["moves"] contains an initial null, idx -= 1 for modeToEvalMap
        let moveEval = moveToEvalMap[Math.max(0, currentMoveIndex - 1)]
        showBoardRefresh(json, currentMoveIndex, moveEval)
        e.preventDefault()
      }
    }
    window.removeEventListener('keydown', windowKeyEventListeners.pop())
    window.addEventListener('keydown', keydownListener)
    windowKeyEventListeners.push(keydownListener)
  }
  json["moves"].forEach(function(move, index) {
    if (move) {
      function clickFunction(event) {
        event.target.classList.add("selected")
        currentMoveIndex = index;
        json["game"]["pieces"] = moveToPiecesMap[index];
        showBoardRefresh(json, index, moveToEvalMap[index])
      }

      // Move number
      let moveCell = document.createElement("td");
      moveCell.innerHTML = "<span style='color:wheat'>" + (1 + Math.floor(move.move_count / 2)) + "</span>"

      // Move notation
      let notationCell = document.createElement("td");
      notationCell.innerHTML = "" + move.notation
      notationCell.setAttribute("data-id", index)
      notationCell.addEventListener("click", clickFunction)

      // For white, create a new row
      if (index % 2 === 1) {
        row = document.createElement("tr")
        row.appendChild(moveCell)
        row.appendChild(notationCell)
        list.appendChild(row);

      // Add black to previously created row
      } else {
        row.appendChild(notationCell)
      }

    }
  })
  movesList.appendChild(list);
  if (selectedId) {
    let cell = document.querySelector("#moves-list td[data-id='" + selectedId + "']");
    cell.classList.add("selected");
  }
  // Show eval bar
  if (showEval !== false) {

    // Unhide elements and restore colors

    let evalCont = document.getElementById("eval-container")
    evalCont.classList.remove("hidden")
    evalCont.style = "background-color: white;"

    let topBar = document.getElementById("eval-black")
    topBar.classList.remove("hidden")
    topBar.style = "background-color: black;"

    // Calculate heights based on given showEval value
    // Total scale = 20 pawns or 2000 cp units
    let cpLimit = 1000
    let evaluation = 0;
    if (showEval > 0) {
      evaluation = Math.min(238, (showEval * 238 / cpLimit))
    } else {
      evaluation = Math.max(-238, (showEval * 238 / cpLimit))
    }
    let heightWhite = 238 + evaluation
    let heightBlack = 238 - evaluation

    // Swap if game is black-facing

    if (gameView.showTurn === "black") {
      evalCont.style = "background-color: black;"
      topBar.style = "background-color: white; height: " + heightWhite + "px;"
    } else {

      topBar.style = "height: " + heightBlack + "px;"
    }
  }
}


function gameViewHtml(game) {
  let id = game["id"];

  let moveCt = 0;
  if (game.move_count >= 1) {
    moveCt = game.move_count - 1;
  }
  let moveStr = "" + moveCt + " moves";
  
  if (game.move_count === 2) {
    moveStr = "1 move";
  }

  let divStyle = 'width: 90%; height: 90%; margin: auto; position: relative; background-color: rgba(30,8,0,0.3);';

  // Check if server returned a cached version of thumbnail

  if (game.thumbnail) {
    divStyle += 'background-image: url("' + game.thumbnail + '");';
    divStyle += 'background-size: contain;';
    divStyle += 'background-blend-mode: overlay;';
  }

  let htmlString = "<div class='game-thumbnail' " + 
                        "style='width:100%; height:100%;'>";

  htmlString += "<div style='" + divStyle + "'>";
  htmlString += "<span><b>" +
                getGameTitle(game) +
                "</b></span>";
  htmlString += "<br><br>"
  htmlString += "<span style='color: white;'>" + moveStr + "</span>";
  htmlString += "<br>";
  htmlString += "<a href='#' class='get-board' id='get-board' data-id='" + id + "'>";
  htmlString += "<span>View Game</span>";

  if (game.difficulty) {
    htmlString += "<br><br><span style='color: white;'>Difficulty: " + game.difficulty + "</span>";
  }
  htmlString += "</a>";
  htmlString += "</div>";

  htmlString += "</div>";
  return htmlString;
}

function getName(name) {
  if (name === "") {
    return "Computer";
  }
  return name;
}

function getGameTitle(game) {
  let name1 = game["white_name"];
  let name2 = game["black_name"];

  return getName(name1) + " vs. " + getName(name2)
}

getGames();