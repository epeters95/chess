// Common variables

const baseUrl = "https://chess-wpj4.onrender.com";

const canvas = document.getElementById("game-view");
var context, canvasLeft, canvasTop;

if (!!canvas) {
  context = canvas.getContext("2d");
  canvasLeft = canvas.offsetLeft + canvas.clientLeft;
  canvasTop = canvas.offsetTop + canvas.clientTop;

  canvas.width = (screen.height * .4) - 100;
  canvas.height = canvas.width;
}


const statusSpan = document.getElementById("status");


// Common functions

function fileIndexOf(letter) {
  return "abcdefgh".indexOf(letter);
}
function rankIndexOf(num) {
  return "12345678".indexOf(num);
}

function fileOf(col) {
  return ["a","b","c","d","e","f","g","h"][col]
}

function rankOf(row) {
  return ["1","2","3","4","5","6","7","8"][row]
}

function getAccessCookie() {
  let found = document.cookie.split("; ").find((row) => row.startsWith("accesscode"));
  if (found !== undefined) {
    return found.split("accesscode=")[1];
  } else {
    return '';
  }
}

function getTokenColor() {
  let found = document.cookie.split("; ").find((row) => row.startsWith("color"));
  if (found !== undefined) {
    return found.split("color=")[1];

  } else {
    return '';
  }
}

function getTokenCookie() {
  let found = document.cookie.split("; ").find((row) => row.startsWith("gametoken"));
  if (found !== undefined) {
    return found.split("gametoken=")[1];
  } else {
    return '';
  }
}

function setTokenCookie(token, color=null, code=null) {
  document.cookie = 'gametoken=' + token + '; path=/'
  document.cookie = 'color=' + color + '; path=/'
  document.cookie = 'accesscode=' + code + '; path=/'
  document.getElementById("cookieholder").innerText = token;
  document.getElementById("cookieholder-color").innerText = color;
}

function fetchFromApi(endpoint, method, params=null, successCallback=null) {
  let spinner = showSpinner("spinner-div");
  let apiUrl = baseUrl + endpoint;
  let requestObj = {
    method: method
  }

  if (params !== null) {
    if (params["pgn_text"] !== undefined) {
      const formData = new FormData();
      formData.append('pgn_text', params["pgn_text"]);
      requestObj.body = formData;
    } else {
      requestObj.body = JSON.stringify(params);
      requestObj.headers = {
        "Content-Type": "application/json",
        "Accept": "application/json"
      }
    }
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
  let loader = document.getElementById("loading-spinner");
  if (!loader) {
    let spinner = document.createElement('div');
    spinner.id = "loading";
    spinner.innerHTML = '<div id="loading-spinner"><img src="img/spinner2.gif"></div>';
    document.getElementById(canvasParentId).appendChild(spinner);
    // Add hide function for spinner
    spinner.hide = function() {
      spinner.classList.add("hidden");
    }
    return spinner
  } else {
    let spinner = document.getElementById("loading");
    spinner.classList.remove("hidden");
    return spinner;
  }
}

function hideQuote() {
  let quoteSpan = document.getElementsByClassName("quote-span")[0]
  if (quoteSpan !== undefined) {
    quoteSpan.classList.add("hidden")
  }
}