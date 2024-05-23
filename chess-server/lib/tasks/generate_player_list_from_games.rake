namespace :api do
  desc "Creates list of players within any currently saved games"

  task generate_player_list_from_games: [:environment] do |t|

    player_names = Game.unique_player_names
    players = []

    player_names.each do |player_name|
      players << Player.create(name: player_name)
    end

    # Update references on game objects
    players.each do |player|

      games = Game.where(white_name: player.name).or(Game.where(black_name: player.name))
      games.each do |game|
        game.update(black_id: player.id) if game.black_name == player.name
        game.update(white_id: player.id) if game.white_name == player.name
      end

    end
  end
end