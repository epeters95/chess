Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  root "test#status"

  get '/404', to: 'errors#not_found'
  get '/500', to: 'errors#server_error'

  namespace :api do

    resources :games, except: [:delete, :new, :edit] do
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
    resources :players, only: [:show, :update, :index, :destroy]

    resources :live_games, only: [:create, :update, :show]
    # api_live_games  PATCH    /api/      games(.:format)           api/live_games#update

    resources :boards, only: [:create, :show]

    # Viewing game via access code
    get '/live_games/', to: 'live_games#show'
    get '/quote', to: 'games#quote'
  end


  # Test status endpoint
  get '/status', to: 'test#status'

  # devise_for :users, controllers: {
  #   sessions: 'api/sessions'
  # }

end
