class GameView {

  constructor(canvas, json, domElements, isLive=false, computerTeam=null, showTurn=null, difficulty=null, eloRating=null) {

    this.canvas = canvas;
    this.context = canvas.getContext("2d");
    this.squareSize = canvas.width / 8.0;

    // Set game-specific vars contained in response JSONs
    this.showTurn = showTurn;
    this.setJsonVars(json);

    this.isLive = isLive;
    this.computerTeam  = computerTeam;
    this.difficulty = difficulty;
    this.eloRating = eloRating;
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
    this.resignButton    = domElements["resignButton"];

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
    this.uploaded      = json["uploaded"];
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

  draw(skipLoop=false, callback=()=>{}, animatePiecePos=null, animatePos=null) {

    this.statusSpan.innerText = this.status;

    this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);

    this.switchSquareColor()

    let thisTurn = this.turn

    if (!this.isLive) {
      if (this.turnName !== "") {
        this.showTurn = thisTurn;
      } else {
        this.showTurn = ["white", "black"].filter((el) => {return el !== thisTurn })[0]
      }
    }

    let that = this;

    new Promise((resolve) => {

      that.drawBoard()
      resolve()

    }).then(() => {

      that.drawTeam("white", animatePiecePos, animatePos)

    }).then(() => {

      that.drawTeam("black", animatePiecePos, animatePos)

    }).then(() => {

      that.showSelectionGrid()

    }).then(() => {

      that.drawMoves()

    }).then(() => {

      callback()

      if (that.gameStatus !== "completed") {
        if (that.isLive && that.showTurn !== that.turn && !skipLoop) {
          that.checkForMoveLoop();
        }
        if (that.resignButton) {
          that.resignButton.classList.remove("hidden")
          that.resignButton.addEventListener("click", function() {
            that.resignButton.setAttribute("disabled", true)
            that.resign()
          })
        }
      }
      else {
        if (this.resignButton) {
          this.resignButton.classList.add("hidden")
        }
      }
      that.canvas.click()
    })

  }

  getShowWhite() {
    let showWhite;

    if (this.showTurn !== null) {
      showWhite = (this.showTurn === "white");
    } else {
      showWhite = (this.turn === "white" || this.turnName === "");
    }
    return showWhite;
  }

  drawTeam(color, animatePiecePos=null, animatePos=null) {
    this.context.font = `50px Verdana`;
    let smallSize = this.squareSize * 0.9;
    let tinySize = this.squareSize * 0.1;
    let squareSize = this.squareSize;
    let that = this;

    this.pieces[color].forEach(function(el) {
      that.context.fillStyle = color;
      let x, y;

      if (that.getShowWhite()) {
        x = fileIndexOf(el.position[0]) * squareSize;
        y = (7 - rankIndexOf(el.position[1])) * squareSize;
      } else {
        x = (7 - fileIndexOf(el.position[0])) * squareSize;
        y = rankIndexOf(el.position[1]) * squareSize;
      }
      if (animatePiecePos !== null && el.position === animatePiecePos) {
        that.context.fillText(el.char, animatePos[0] + tinySize, animatePos[1] + smallSize)
      }
      else {
        that.context.fillText(el.char, x + tinySize, y + smallSize);
      }
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
        this.context.fillStyle = this.switchSquareColor();
        this.context.fillRect(x, y, this.squareSize, this.squareSize);
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

    let reqBody = {};
    if (this.difficulty) {
      reqBody["computer_difficulty"] = this.difficulty;
    }
    else if (this.eloRating) {
      reqBody["elo_rating"] = this.eloRating;
    }

    fetchFromApi("/api/games/" + this.gameId, "PATCH", reqBody, function(json) {
      that.setJsonVars(json);
      that.draw();
    })

  }

  selectMove(move) {

    if (move["move_type"] === "promotion" || move["move_type"] === "attack_promotion") {
      this.promotionMove = move;
      this.promotionPopup.classList.remove("hidden");
    } else {
      this.playMove(move);
    }

  }

  playMove(move) {
    this.sendGameUpdateAndRedraw({ "move": move })
  }

  resign() {
    this.sendGameUpdateAndRedraw({ "end_game": this.showTurn })
  }

  sendGameUpdateAndRedraw(data) {
    let that = this;
    this.clearHighlight();

    const sendGameUpdate = function() {
      fetchFromApi("/api/games/" + that.gameId, "PATCH", data, function(json) {
        that.promotionMove = null;
        that.selectedMoves = [];
        that.setJsonVars(json);
        that.draw();
        if (!data["resign"] && !that.isLive && that.computerTeam === that.turn) {
          that.nextComputerMove();
        }
      })
    }

    // if (data["move"] !== undefined ) {
    //   this.playMoveAnimation(data["move"], sendGameUpdate)
    // } else {
      sendGameUpdate()
    // }

  }

  xToCanvasPosition(file) {
    if (this.getShowWhite()) {
      return (7 - fileIndexOf(file)) * this.squareSize;
    } else {
      return fileIndexOf(file) * this.squareSize;
    }
  }

  yToCanvasPosition(rank) {
    if (this.getShowWhite()) {
      return (7 - rankIndexOf(rank)) * this.squareSize;
    } else {
      return rankIndexOf(rank) * this.squareSize;
    }
  }

  playMoveAnimation(move, callback) {
    let steps = 30;

    let oldX = this.xToCanvasPosition(move.position[0]);
    let newX = this.xToCanvasPosition(move.new_position[0]);
    let oldY = this.yToCanvasPosition(move.position[1]);
    let newY = this.yToCanvasPosition(move.new_position[1]);

    let xDiff = newX - oldX;
    let yDiff = newY - oldY;

    let incrX = xDiff / steps;
    let incrY = yDiff / steps;

    let totalX = oldX;
    let totalY = oldY;

    let that = this;

    const loopAnimate = function() {
      setTimeout(function() {
        totalX += incrX
        totalY += incrY

        if (totalX === newX && totalY === newY) {
          callback();
          return;

        } else {
          that.draw(true, loopAnimate, move.position, [totalX, totalY])
        }
      }, 24)
    }

    loopAnimate();
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