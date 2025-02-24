const playersTable = document.getElementById("players-table");

let spinner = showSpinner("spinner-div");

fetchFromApi('/api/players', 'GET', null, function(json) {
  let tableHeader = document.createElement('tr')
  tableHeader.innerHTML = "<th>Name</th>" +
                          "<th># Games</th>" +
                          "<th>Completed</th>" +
                          "<th>Wins</th>" +
                          "<th>Losses</th>" +
                          "<th>Draws</th>";
  playersTable.appendChild(tableHeader);

  // Currently, this client is using the initial method of linking users games
  // which is purely by unique name usage.
  // To support future features linking players by id, this search endpoint will
  // also support fetching games by white_id and black_id (not yet simply "id"...)
  // in addition to "status" and quick ability to add more in the future
  json["players"].forEach(function(player) {
    let tableRow = document.createElement('tr');
    let link = 'games_index.html?name=' + player.name;

    let tableCells = "<td>" + player.name + "</td><td>";
    if (player.games > 0) {
      tableCells += player.games;
    }
    tableCells += "</td><td>";

    if (player.completed_games > 0) {
      tableCells += "<a href='" + link + "&status=completed" + "'>" + player.completed_games + "</a>"
    }
    tableCells += "</td><td>";

    if (player.wins > 0) {
      tableCells += "<a href='" + link + "&wins=" + player.id + "'>" + player.completed_games + "</a>"
    }
    tableCells += "</td><td>";

    if (player.losses > 0) {
      tableCells += "<a href='" + link + "&losses=" + player.id + "'>" + player.completed_games + "</a>"
    }
    tableCells += "</td><td>";

    if (player.draws > 0) {
      tableCells += "<a href='" + link + "&draws=" + player.id + "'>" + player.completed_games + "</a>"
    }
    tableCells += "</td>";

    tableRow.innerHTML = tableCells;
    playersTable.appendChild(tableRow)
  })
  spinner.hide();
})
