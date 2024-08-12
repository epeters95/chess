// Common variables

const baseUrl = "https://chess-wpj4.onrender.com";
// const baseUrl = "http://localhost:3000";

const canvas = document.getElementById("game-view");

if (canvas) {
  canvas.width = 476;
  canvas.height = 476;
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
  if (found) {
    return found.split("accesscode=")[1];
  } else {
    return '';
    // return document.getElementById("cookieholder-accesscode").innerHTML;
  }
}

function getTokenColor() {
  let found = document.cookie.split("; ").find((row) => row.startsWith("color"));
  if (found) {
    return found.split("color=")[1];

  } else {
    return '';
    // return document.getElementById("cookieholder-color").innerHTML;
  }
}

function getTokenCookie() {
  let found = document.cookie.split("; ").find((row) => row.startsWith("gametoken"));
  if (found) {
    return found.split("gametoken=")[1];
  } else {
    return '';
    // return document.getElementById("cookieholder-token").innerHTML;
  }
}

function setTokenCookie(token, color='', code='') {
  document.cookie = 'gametoken=' + token + '; path=/'
  document.cookie = 'color=' + color + '; path=/'
  document.cookie = 'accesscode=' + code + '; path=/'

  // if (document.getElementById("cookieholder-token")) {
  //   document.getElementById("cookieholder-token").innerHTML = token;
  // }
  // if (document.getElementById("cookieholder-color")) {
  //   document.getElementById("cookieholder-color").innerHTML = color;
  // }
  // if (document.getElementById("cookieholder-accesscode")) {
  //   document.getElementById("cookieholder-accesscode").innerHTML = code;
  // }
  // console.log("Set cookie vals: token:" + token + ", color: " + color + ", code: " + code)
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
      console.log("Error:" + json.error + " " + json.errors)
    }
    spinner.hide()
  })
  .catch(function(error) {
    console.log("Error: " + error)
    spinner.hide()
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