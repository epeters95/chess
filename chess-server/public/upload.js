const pgnForm = document.getElementById("upload-pgn-form");

const pgnSubmit = document.getElementById("upload-pgn-submit");

pgnSubmit.addEventListener("click", function(event) {

  let files = pgnForm.children[1].files;
  if (files.length > 0) {
    fetchFromApi("/api/boards/", "POST", {"pgn_text": files[0]}, function() {
      console.log("File uploaded successfully!");

    })
  }

})