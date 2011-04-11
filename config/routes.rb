Paranoia::Application.routes.draw do  
  resources :users
  resources :pawns
  resources :sessions, :only => [:new, :create, :destroy]
  resources :updaters
  resources :gamestates do
    member do
      get :bogusdata
    end
  end
  
  match '/signup',  :to => 'users#new'

  match '/contact', :to => 'pages#contact'
  match '/about',   :to => 'pages#about'
  match '/help',    :to => 'pages#help'
  
  match '/signin',  :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'

  match '/creategame', :to => 'lobbies#lobbies'
  match '/newgame', :to => 'lobbies#new'
  
  match '/joingame', :to => 'pawns#new'
  match '/mygames', :to => 'gamestates#mygames'
  
  match '/update', :to => 'updaters#update'
  
  root :to => 'pages#home'
end
