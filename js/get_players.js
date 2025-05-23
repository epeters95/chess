$(document).ready(function() {

  const wrapLink = function(params, playerName, data) {
  // Currently, this client is using the initial method of linking users games
  // which is purely by unique name usage.
  // To support future features linking players by id, this search endpoint will
  // also support fetching games by white_id and black_id (not yet simply "id"...)
  // in addition to "status" and quick ability to add more in the future
    if (data !== 0) {
      let link = 'games_index.html?name=' + playerName;
      return "<a href='" + link + params + "'>" + data + "</a>"
    }
    return "";
  }

  const completedLink = function(data, type, row) {
    return wrapLink("&status=completed", row.name, data)
  };

  // These DataTable row keys are /?search query parameters representing the player's id
  // E.g. 'wins_id', 'losses_id', 'draws_id', 'checkmates_id', 'resignations_id'

  const renderLinkByFilter = function(data, type, row, meta) {

    // Grab the name of the filter by adding 1 to the idx because DT excludes id :'(
    let filterName = Object.getOwnPropertyNames(row)[meta.col + 1]
    let filter = "&" + filterName + "=" + row.id

    return wrapLink(filter, row.name, data)
  }

  new DataTable('#players-table', {
    responsive: true,
    ajax: {
      "url": baseUrl + '/api/players',
      "type": "GET",
      "dataSrc": "players"
    },
    layout: {
      top: {
        search: {
          placeholder: 'Search'
        }
      },
      bottom: 'info',
      topEnd: null,
      topStart: null,
      bottomStart: null,
      bottomEnd: null
    },
    columns: [
      { data: 'name'},
      { data: 'games', orderSequence: ['desc', 'asc']},
      { render: completedLink, data: 'completed_games', orderSequence: ['desc', 'asc'] },
      { render: renderLinkByFilter, data: 'wins_id', orderSequence: ['desc', 'asc'] },
      { render: renderLinkByFilter, data: 'losses_id', orderSequence: ['desc', 'asc'] },
      { render: renderLinkByFilter, data: 'draws_id', orderSequence: ['desc', 'asc'] },
      { render: renderLinkByFilter, data: 'checkmates_id', orderSequence: ['desc', 'asc'] },
      { render: renderLinkByFilter, data: 'resignations_id', orderSequence: ['desc', 'asc'] },
      { data: 'highest_elo_win', orderSequence: ['desc', 'asc'] }
    ],
    lengthChange: false,
    paging: false
  });

})
