let table = document.getElementById("game-table");

let modalGames = document.getElementsByClassName("modal")[0];
let modalCloseBtnGames = document.getElementById("modal-close-button");
modalCloseBtnGames.addEventListener("click", function() {
  modalGames.classList.add("hidden");
})

let movesList = document.getElementById("moves-list");
var gameView = null;

// Initialize map variable
var moveToPiecesMap = {};
var movesMap = {};

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
    boardUrl += "#with_history=true"
    el.addEventListener("click", function() {
      fetchFromApi(boardUrl, "GET", null, function(json) {
        populateGameAndMoves(json);
      })

    })
  });
}

function populateGameAndMoves(json) {
  // Populate snapshots of the game at each move
  json["moves"].forEach(function(move, i) {
    moveToPiecesMap[i] = json["pieces_history"][i];
  })

  showBoardRefresh(json, null)
}

function showBoardRefresh(json, selectedId) {
  modalGames.classList.remove("hidden");
  gameView = new GameView(canvas, json, {"statusSpan": statusSpan}, false)

  new Promise((resolve) => {
    gameView.draw()
    resolve()

  }).then(() => {
    // Populate moves sidebar
    drawMoveList(json, selectedId)
  })
  
}

function drawMoveList(json, selectedId) {
  movesList.innerHTML = "";
  let list = document.createElement("table");
  let row;
  let selId = selectedId;
  if (json["moves"].length === 0) {
    let span = document.createElement("span");
    span.innerHTML = "No moves played";
    movesList.appendChild(span);
    return;
  }
  json["moves"].forEach(function(move, index) {
    if (move) {
      function clickFunction(event) {
        event.target.classList.add("selected")
        json["game"]["pieces"] = moveToPiecesMap[index];
        showBoardRefresh(json, index)
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
    let cell = document.querySelector("[data-id='" + selectedId + "']");
    cell.classList.add("selected");
  }
}


function gameViewHtml(game) {
  let id = game["id"];
  let name1 = game["white_name"];
  let name2 = game["black_name"];

  let moveStr = "" + (game.move_count - 1) + " moves";
  if (game.move_count === 2) {
    moveStr = "1 move";
  }

   + id + "/board";
  let htmlString = "<div class='game-thumbnail' style='width:100%; height:100%'>";

  htmlString += "<div style='width: 90%; height: 90%; margin: auto; position: relative; background-color: rgba(0,0,0,0.2);'>";
  htmlString += "<span><b>" +
                getName(name1) + " vs. " +
                getName(name2) +
                "</b></span>";
  htmlString += "<br><br>"
  htmlString += "<span style='color: white;'>" + moveStr + "</span>";
  htmlString += "<br>";
  htmlString += "<a href='#' class='get-board' id='get-board' data-id='" + id + "'>";
  htmlString += "<span>View Game</span>";
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

getGames();