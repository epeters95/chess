const pgnForm = document.getElementById("upload-pgn-form");
const pgnSubmit = document.getElementById("upload-pgn-submit");

const modal = document.getElementsByClassName("modal")[0];
const modalCloseBtn = document.getElementById("modal-close-button");
modalCloseBtn.addEventListener("click", function() {
  modal.classList.add("hidden");
})

pgnSubmit.addEventListener("click", function() {

  let files = pgnForm.children[1].files;
  if (files.length > 0) {
    fetchFromApi("/api/boards/", "POST", {"pgn_text": files[0]}, function() {

      // Upload success popup
      modal.classList.remove("hidden")
    })
  }

})