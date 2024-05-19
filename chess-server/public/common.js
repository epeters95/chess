// Common variables

const canvas = document.getElementById("game-view");
const context = canvas.getContext("2d");
const canvasLeft = canvas.offsetLeft + canvas.clientLeft;
const canvasTop = canvas.offsetTop + canvas.clientTop;

canvas.width = (screen.height * .4) - 100;
canvas.height = canvas.width;

const statusSpan = document.getElementById("status");


// Common functions

function fileIndexOf(letter) {
  return "abcdefgh".indexOf(letter);
}
function rankIndexOf(num) {
  return "12345678".indexOf(num);
}

function getAccessCookie() {
  return document.cookie.split("; ").find((row) => row.startsWith("accesscode"));
}

function getTokenColor() {
  let cookie = document.cookie.split("; ").find((row) => row.startsWith("color"));
  return (cookie || document.getElementById("cookieholder-color").innerText);
}

function getTokenCookie() {
  return document.cookie.split("; ").find((row) => row.startsWith("gametoken"))
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
  let apiUrl = "http://localhost:3000" + endpoint;
  let requestObj = {
    method: method,
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json"
    }
  }
  if (params !== null) {
    requestObj.body = JSON.stringify(params);
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
  let spinner = document.createElement('div');
  spinner.id = "loading";
  spinner.innerHTML = '<div id="loading-spinner"><img src="spinner2.gif"></div>';
  document.getElementById(canvasParentId).appendChild(spinner);

  // Add hide function for spinner
  spinner.hide = function() {
    this.classList.add("hidden");
  }

  return spinner
}