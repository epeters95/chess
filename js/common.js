// Common variables

const baseUrl = "https://chess-wpj4.onrender.com";


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
  }
}

function getTokenColor() {
  let found = document.cookie.split("; ").find((row) => row.startsWith("color"));
  if (found) {
    return found.split("color=")[1];

  } else {
    return '';
  }
}

function getTokenCookie() {
  let found = document.cookie.split("; ").find((row) => row.startsWith("gametoken"));
  if (found) {
    return found.split("gametoken=")[1];
  } else {
    return '';
  }
}

function setTokenCookie(token, color='', code='') {
  document.cookie = 'gametoken=' + token + '; path=/'
  document.cookie = 'color=' + color + '; path=/'
  document.cookie = 'accesscode=' + code + '; path=/'
}

function fetchFromApi(endpoint, method, params=null, successCallback=null, hideSpinner=false) {
  let spinner;
  if (!hideSpinner) {
    spinner = showSpinner("spinner-div");
  }
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
  })
  .catch(function(error) {
    console.log("Error: " + error)
  })
  .finally(function() {

    if (spinner !== undefined) {
      spinner.classList.add("hidden");
    }
  })
}

function showSpinner(canvasParentId) {
  let loader = document.getElementById("loading-spinner");
  if (!loader) {
    let spinner = document.createElement('div');
    spinner.id = "loading";
    spinner.innerHTML = '<div id="loading-spinner"><img src="img/spinner2.gif"></div>';
    document.getElementById(canvasParentId).appendChild(spinner);
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