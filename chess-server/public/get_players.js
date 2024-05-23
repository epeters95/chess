const playersTable = document.getElementById("players-table");

let spinner = showSpinner("players-table");

const players = fetchFromApi('/api/players', 'GET', null, function(json) {
  let tableHeader = document.createElement('tr')
  tableHeader.innerHTML = "<th>Name</th><th># Games</th><th>Completed</th>";
  playersTable.appendChild(tableHeader);
  json["players"].forEach(function(player) {
    let tableRow = document.createElement('tr');
    tableRow.innerHTML = "<td>" +
                   player.name + "</td><td>" +
                   player.games + "</td><td>" +
                   player.completed_games + "</td>";
    playersTable.appendChild(tableRow)
  })
  spinner.hide();
})
