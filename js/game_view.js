class GameView {

  constructor(canvas, json, domElements, isLive=false, computerTeam=null, showTurn=null) {

    this.canvas = canvas;
    this.context = canvas.getContext("2d");
    this.squareSize = canvas.width / 8.0;

    // Set game-specific vars contained in response JSONs
    this.showTurn = showTurn;
    this.setJsonVars(json);

    this.isLive = isLive;
    this.computerTeam  = computerTeam;
    this.selectedMoves = [];
    this.selectedPiece = "";
    this.accessCode    = "";
    this.token         = "";
    this.color         = "";

    this.eventListeners = {
      "mouseenter": [],
      "mouseleave": [],
      "click": []
    }; // E.g. { type: [[domElement, listener], ...], ... }

    this.colorW = "#97aaac";
    this.colorB = "#556567";
    this.squareColor = this.colorB;

    // DOM elements
    this.statusSpan      = domElements["statusSpan"];
    this.promotionPopup  = domElements["promotionPopup"];
    this.promotionSubmit = domElements["promotionSubmit"];

    this.gridShown = false;
    this.refreshRateMs = 5000;
    this.promotionMove = null;

    // Set up promotion event handler once
    let that = this;
    if (this.promotionPopup && this.promotionSubmit) {
      this.promotionSubmit.addEventListener("click", function() {
        // Only promote when a promotion move has been selected
        if (that.promotionMove) {
          let promotionChoices = document.getElementsByName("promotion-choice");
          let checkedChoice = Array.from(promotionChoices).find((choice) => { return choice.checked });
          that.promotionMove["promotion_choice"] = checkedChoice.value;
          that.playMove(that.promotionMove)
        }
      })
    }
  }

  setJsonVars(json) {
    if (json["game"] !== undefined) {
      json = json["game"]
    }
    this.currentJson   = json;
    this.gameId        = json["id"];
    this.status        = json["status_str"];
    this.gameStatus    = json["game_status"];
    this.turn          = json["turn"];
    this.turnName      = json["turn_name"];
    this.pieces        = JSON.parse(json["pieces"]);
    this.moves         = json["legal_moves"].map((lm) => JSON.parse(lm));
  }

  refresh() {

    this.accessCode = getAccessCookie()
    this.token = getTokenCookie()
    this.color = getTokenColor()

    let params = "?access_code=" + this.accessCode + "&token=" + this.token + "&color=" + this.color
    let that = this;

    fetchFromApi("/api/live_games/" + params, "GET", null, function(json) {
      that.setJsonVars(json);
      that.draw()
    })

  }

  checkForMoveLoop() {
    let that = this;
    setTimeout(function() {

      if (getTokenColor() !== that.turn) {
        that.refresh()
      }

    }, this.refreshRateMs)
  }

  draw(skipLoop=false) {

    this.statusSpan.innerText = this.status;

    context.clearRect(0, 0, canvas.width, canvas.height);

    this.switchSquareColor()

    let thisTurn = this.turn

    if (!this.isLive) {
      if (this.turnName !== "") {
        this.showTurn = thisTurn;
      } else {
        this.showTurn = ["white", "black"].filter((el) => {return el !== thisTurn })[0]
      }
    }
    console.log("this.showTurn: " + this.showTurn + ", this.turn: " + this.turn + ", this.turnName: " + this.turnName)

    let that = this;

    new Promise((resolve) => {

      that.drawBoard()
      resolve()

    }).then(() => {

      that.drawTeam("white")

    }).then(() => {

      that.drawTeam("black")

    }).then(() => {

      that.showSelectionGrid()

    }).then(() => {

      that.drawMoves()

    }).then(() => {

      if (that.isLive && that.showTurn !== that.turn && !skipLoop && that.gameStatus !== "completed") {
        that.checkForMoveLoop();
      }
      canvas.click()
    })

  }

  drawTeam(color) {
    context.font = `50px Verdana`;
    let smallSize = this.squareSize * 0.9;
    let tinySize = this.squareSize * 0.1;
    let squareSize = this.squareSize;
    let that = this;

    this.pieces[color].forEach(function(el) {
      that.context.fillStyle = color;
      let x, y;
      let showWhite;

      if (that.showTurn !== null) {
        showWhite = (that.showTurn === "white");
      } else {
        showWhite = (that.turn === "white" || that.turnName === "");
      }

      if (showWhite) {
        x = fileIndexOf(el.position[0]) * squareSize;
        y = (7 - rankIndexOf(el.position[1])) * squareSize;
      } else {
        x = (7 - fileIndexOf(el.position[0])) * squareSize;
        y = rankIndexOf(el.position[1]) * squareSize;
      }
      that.context.fillText(el.char, x + tinySize, y + smallSize);
    })
  }

  selectPiece(piece) {
    if (this.isThisTurn()) {
      if (this.selectedPiece !== piece || this.selectedPiece === "") {
        this.selectedPiece = piece;
        this.selectedMoves = this.moves.filter(function(move) {
          let pc = JSON.parse(move.piece_str)
          return pc.position === piece.position
        })
      }
      else {
        this.selectedPiece = "";
        this.selectedMoves = [];
      }
      this.draw(true);
    }
  }

  drawMoves() {

    if (this.currentJson !== undefined && this.isThisTurn()) {

      let squareSize = this.squareSize;
      let that = this;

      this.selectedMoves.forEach(function(move) {
        let x, y;
        if (that.turn === "white") {
          x = fileIndexOf(move.new_position[0]) * squareSize;
          y = (7 - rankIndexOf(move.new_position[1])) * squareSize;
        } else {
          x = (7 - fileIndexOf(move.new_position[0])) * squareSize;
          y = rankIndexOf(move.new_position[1]) * squareSize;
        }
        let halfSquare = squareSize / 2.0;
        let tinySize = squareSize * 0.1;
        let bgColor = ( (fileIndexOf(move.new_position[0]) + rankIndexOf(move.new_position[1])) % 2 === 1) ? that.colorB : that.colorW;
        const grd = that.context.createRadialGradient(
          x + halfSquare,
          y + halfSquare,
          0,
          x + halfSquare,
          y + halfSquare,
          tinySize
          );

        grd.addColorStop(0, that.turn);
        grd.addColorStop(1, bgColor);
        // Draw a filled Rectangle
        that.context.fillStyle = grd;
        that.context.fillRect(
          x,
          y,
          squareSize,
          squareSize
          );
      })
    }
  }

  drawBoard() {

    for (let x = 0; x <= this.canvas.width; x += this.squareSize) {
      for (let y = 0; y <= this.canvas.width; y += this.squareSize) {
        context.fillStyle = this.switchSquareColor();
        context.fillRect(x, y, this.squareSize, this.squareSize);
      }
    }
  }

  switchSquareColor() {
    this.squareColor = (this.squareColor === this.colorW ? this.colorB : this.colorW);
    return this.squareColor;
  }

  showSelectionGrid() {
    if (this.gameStatus === "completed") {
      return null;
    }

    let grid = document.getElementById("selection-grid");
    if (grid) {
      grid.classList.remove("hidden");
    }
    // In case grid element is reused, save func declarations to remove event listeners
    const highlight = (event) => { event.target.classList.add("highlighted") }
    const unhighlight = (event) => { event.target.classList.remove("highlighted") }

    let that = this;

    const click = (event) => {
      var fileIndex = event.target.cellIndex;
      var rankIndex = event.target.closest("tr").rowIndex;

      // Map cell indices to board orientation
      if (that.showTurn === "white") {
        rankIndex = 7 - rankIndex;
      } else {
        fileIndex = 7 - fileIndex;
      }
      let thisSquare = fileOf(fileIndex) + rankOf(rankIndex);

      // Show moves if clicking piece
      let cellPiece = that.pieces[that.showTurn].filter((piece) => {
        return (piece.position === thisSquare)
      })
      if (cellPiece.length === 1) {
        that.selectPiece(cellPiece[0])
      }

      // Play move if clicking move
      let cellMove = that.selectedMoves.filter((mv) => {
        return (mv.new_position === thisSquare)
      })
      if (cellMove.length === 1) {
        removeEventListenersAndCall(grid, that, () => {
          that.selectMove(cellMove[0])
        })
      }
    }

    const removeEventListenersAndCall = (grid, that, callFunc) => {
      new Promise((resolve) => {
        Object.keys(that.eventListeners).forEach((key) => {
          that.eventListeners[key].forEach((elArr) => {
            elArr[0].removeEventListener(key, elArr[1])
          })
        })
        that.gridShown = false; // trigger re-draw
        resolve()
      }).then(() => {
        callFunc()  // Should be selectMove, which fetches then calls draw()
      })
    }

    // Triggered re-draw of board + events

    if (!this.gridShown && !!grid) {
      this.gridShown = true;
      Array.from(grid.firstElementChild.children).forEach((row) => {
        Array.from(row.children).forEach((cell) => {
          cell.addEventListener("mouseenter", highlight)
          cell.addEventListener("mouseleave", unhighlight)
          cell.addEventListener("click", click);

          that.eventListeners["mouseenter"].push([cell, highlight])
          that.eventListeners["mouseleave"].push([cell, unhighlight])
          that.eventListeners["click"].push([cell, click])
        });
      });
    }
  }

  nextComputerMove() {

    let that = this;

    fetchFromApi("/api/games/" + this.gameId, "PATCH", null, function(json) {
      that.setJsonVars(json);
      that.draw();
    })

  }

  selectMove(move) {

    let that = this;

    if (move["move_type"] === "promotion" || move["move_type"] === "attack_promotion") {
      this.promotionMove = move;
      this.promotionPopup.classList.remove("hidden");
    } else {
      this.playMove(move);
    }

  }

  playMove(move) {
    let that = this;
    fetchFromApi("/api/games/" + this.gameId, "PATCH", { "move": move }, function(json) {
      that.promotionMove = null;
      that.selectedMoves = [];
      that.setJsonVars(json);
      that.draw();
      if (!that.isLive && that.computerTeam === that.turn) {
        that.nextComputerMove();
      }
      that.clearHighlight();
    })
  }

  clearHighlight() {
    let grid = document.getElementById("selection-grid");
    if (grid) {
      Array.from(grid.firstElementChild.children).forEach((row) => {
        Array.from(row.children).forEach((cell) => {
          cell.classList.remove("highlighted")
        })
      })
    }
  }

  isThisTurn() {
    if (this.live) {
      return (this.turn === getTokenColor());
    } else {
      return (this.turnName !== "");
    }
  }
}