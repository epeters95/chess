$(document).ready(function() {

  const wrapLink = function(params, playerName, data) {
  // Currently, this client is using the initial method of linking users games
  // which is purely by unique name usage.
  // To support future features linking players by id, this search endpoint will
  // also support fetching games by white_id and black_id (not yet simply "id"...)
  // in addition to "status" and quick ability to add more in the future
    if (data !== 0) {
      let link = 'games_index.html?name=' + playerName;
      return "<a href='" + link + "&status=completed" + "'>" + data + "</a>"
    }
    return "";
  }

  const completedLink = function(data, type, row, meta) {
    return wrapLink("&status=completed", row.name, data)
  };

  const winsLink = function(data, type, row, meta) {
    return wrapLink("&wins=" + row.id, row.name, data)
  };

  const lossesLink = function(data, type, row, meta) {
    return wrapLink("&losses=" + row.id, row.name, data)
  };

  const drawsLink = function(data, type, row, meta) {
    return wrapLink("&draws=" + row.id, row.name, data)
  };

  let table = new DataTable('#players-table', {
    responsive: true,
    ajax: {
      "url": baseUrl + '/api/players',
      "type": "GET",
      "dataSrc": "players"
    },
    layout: {
      topStart: 'search',
      topEnd: null,
      bottomStart: null,
      bottomEnd: 'info'
    },
    columns: [
      { data: 'name'},
      { data: 'games', orderSequence: ['desc', 'asc']},
      { render: completedLink, data: 'completed_games', orderSequence: ['desc', 'asc'] },
      { render: winsLink, data: 'wins', orderSequence: ['desc', 'asc'] },
      { render: lossesLink, data: 'losses', orderSequence: ['desc', 'asc'] },
      { render: drawsLink, data: 'draws', orderSequence: ['desc', 'asc'] }
    ],
    lengthChange: false,
    paging: false
  });

})
