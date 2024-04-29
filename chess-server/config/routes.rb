Rails.application.routes.draw do
  root "test#index"

  get '/404', to: 'errors#not_found'
  get '/500', to: 'errors#server_error'

  namespace :api do

    resources :games do
    # api_games GET    /api/games(.:format)                api/games#index
    #           POST   /api/games(.:format)                api/games#create
    # api_game  GET    /api/games/:id(.:format)            api/games#show
    #           PATCH  /api/games/:id(.:format)            api/games#update
    #           PUT    /api/games/:id(.:format)            api/games#update
    #           DELETE /api/games/:id(.:format)            api/games#destroy

      resource :board, only: [:show, :update]
      # api_game_board GET    /api/games/:game_id/board(.:format) api/boards#show
      #                PATCH  /api/games/:game_id/board(.:format) api/boards#update
      #                PUT    /api/games/:game_id/board(.:format) api/boards#update
    end

    resources :live_games, only: [:update]
    # api_live_games  PATCH    /api/      games(.:format)           api/live_games#update

  end

  get '/game/:code', to: 'live_games#update'
  get '/testgame', to: 'test#index'
  get '/games', to: 'test#games_index'

end
