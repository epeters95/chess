class GameView {

  constructor(canvas, json, statusSpan, isLive=false, nextMoveSubmitEl=null) {

    this.canvas = canvas;
    this.context = canvas.getContext("2d");
    this.squareSize = canvas.width / 8.0;

    // Set game-specific vars contained in response JSONs
    this.setJsonVars(json);

    this.isLive = isLive;
    this.selectedMoves = [];
    this.selectedPiece = "";
    this.accessCode    = "";
    this.token         = "";

    this.eventListeners = [];

    this.colorW = "#97aaac";
    this.colorB = "#556567";
    this.squareColor = this.colorB;

    // DOM elements
    this.statusSpan     = statusSpan;
    this.nextMoveSubmit = nextMoveSubmitEl;
  }

  setJsonVars(json) {
    if (json["game"] !== undefined) {
      json = json["game"]
    }
    this.currentJson   = json;
    this.gameId        = json["id"];
    this.status        = json["status_str"];
    this.turn          = json["turn"];
    this.turnName      = json["turn_name"];
    this.pieces        = JSON.parse(json["pieces"]);
    this.moves         = json["legal_moves"];

    // TODO: check all response params - possibly unnecessary 
    // this.isLive        = json["is_live"];
  }

  refresh() {

    let params = "?access_code=" + this.accessCode + "&token=" + this.token

    fetchFromApi("/api/live_games/" + params, "GET", null, function(json) {
      this.currentJson = json;
      this.draw()
    })

  }

  checkForMoveLoop() {
    let that = this;
    setTimeout(function() {

      if (getTokenColor() !== that.turn) {
        that.refresh()
      }

    }, 5000)
  }

  draw() {

    this.statusSpan.innerText = this.status;

    context.clearRect(0, 0, canvas.width, canvas.height);

    let thisCanvas = this.canvas;
    this.eventListeners.forEach(function(el) {
      thisCanvas.removeEventListener('click', el);
    })

    this.switchSquareColor()

    let showTurn = (this.isLive ? getTokenColor() : this.turn);

    this.drawBoard();
    this.drawTeam("white", showTurn);
    this.drawTeam("black", showTurn);
    this.showSelectionGrid(showTurn);
    this.drawMoves();

    if (this.isLive) {
      this.checkForMoveLoop();
    }

  }

  drawTeam(color, showTurn=null) {
    context.font = `50px Verdana`;
    let smallSize = this.squareSize * 0.9;
    let tinySize = this.squareSize * 0.1;
    let squareSize = this.squareSize;
    let that = this;

    this.pieces[color].forEach(function(el) {
      that.context.fillStyle = color;
      let x, y;
      let thisTurn, showWhite;
      if (showTurn !== null) {
        showWhite = (showTurn === "white");
        thisTurn = showTurn;
      } else {
        showWhite = (that.turn === "white" || that.turnName === "");
        thisTurn = that.turn
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
    if (this.selectedPiece === "") {
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
    this.draw();
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

      if (!!this.nextMoveSubmit) {
        this.nextMoveSubmit.setAttribute("disabled", true)
      }

    } else {

      if (!!this.nextMoveSubmit) {
        this.nextMoveSubmit.removeAttribute("disabled")
      }
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

  showSelectionGrid(showTurn) {
    let grid = document.getElementById("selection-grid");
    grid.classList.remove("hidden");

    // In case grid element is reused, save func declarations to remove event listeners
    const highlight = (event) => { event.target.classList.add("highlighted") }
    const unhighlight = (event) => { event.target.classList.remove("highlighted") }

    const click = (event) => {
      var fileIndex = event.target.cellIndex;
      var rankIndex = event.target.closest("tr").rowIndex;

      // Map cell indices to board orientation
      if (showTurn === "white") {
        rankIndex = 7 - rankIndex;
      } else {
        fileIndex = 7 - fileIndex;
      }
      let thisSquare = fileOf(fileIndex) + rankOf(rankIndex);

      // Show moves if clicking piece
      let cellPiece = this.pieces[showTurn].filter((piece) => {
        return (piece.position === thisSquare)
      })
      if (cellPiece.length === 1) {
        that.selectPiece(cellPiece[0])
      }

      // Play move if clicking move
      let cellMove = this.moves.filter((mv) => {
        return (mv.new_position === thisSquare)
      })
      if (cellMove.length === 1) {
        that.selectMove(cellMove[0])
      }
    }

    this.highlight = highlight.bind(this);
    this.unhighlight = unhighlight.bind(this);
    this.click = click.bind(this);

    let that = this;

    Array.from(grid.firstElementChild.children).forEach((row) => {
      Array.from(row.children).forEach((cell) => {
        cell.removeEventListener("mouseenter", this.highlight)
        cell.removeEventListener("mouseleave", this.unhighlight)
        cell.addEventListener("mouseenter", this.highlight)
        cell.addEventListener("mouseleave", this.unhighlight)

        if (cell.cellIndex === 0 && cell.closest('tr').rowIndex === 5) debugger
        cell.removeEventListener("click", this.click);
        cell.addEventListener("click", this.click);
      });
    });
  }

  nextComputerMove() {

    fetchFromApi("/api/games/" + this.gameId, "PATCH", null, function(json) {
      this.setJsonVars(json);
      this.draw();
    })

  }

  selectMove(move) {

    fetchFromApi("/api/games/" + this.gameId, "PATCH", { "move": move }, function(json) {
      this.setJsonVars(json);
      this.draw();
    })

  }

  isThisTurn() {
    if (this.live) {
      return (this.turn === getTokenColor());
    } else {
      return (this.turnName !== "");
    }
  }
}