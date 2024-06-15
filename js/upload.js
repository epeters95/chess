const pgnForm = document.getElementById("upload-pgn-form");
const pgnSubmit = document.getElementById("upload-pgn-submit");
const uploadStatusSpan = document.getElementById("upload-status-span");

pgnSubmit.addEventListener("click", function() {

  let files = pgnForm.children[1].files;
  if (files.length > 0) {
    fetchFromApi("/api/boards/", "POST", {"pgn_text": files[0]}, function() {
      uploadStatusSpan.innerHTML = "Upload Successful!";
    })
  }

})