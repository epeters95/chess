Rails.application.routes.draw do
  root "api/games#index"

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

    get '/testgame', to: 'games#create'
  end

end
