Paranoia::Application.routes.draw do  
  resources :users
  resources :pawns
  resources :sessions, :only => [:new, :create, :destroy]
  resources :updaters
  resources :lobbies, :path_names => { :edit => 'leave' }
  resources :gamestates, :only => [:create]
  
  resources :lobbies do
    member do
      get :leave
    end
  end
  
  resources :gamestates do
    member do
      
      get :ajax_gamestate
      get :ajax_ship
      get :ajax_possibleactions
      get :bogusdata
    end
  end
  
  match '/tempIndex', :to => 'pages#tempIndex'
  
  match '/signup',  :to => 'users#new'

  match '/contact', :to => 'pages#contact'
  match '/about',   :to => 'pages#about'
  match '/help',    :to => 'pages#help'
  
  match '/signin',  :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'

  match '/lobbies', :to => 'lobbies#index'
  #match '/lobbies/:id', :to => 'lobbies#show'
  #match '/lobbies/leave/:id', :to => 'lobbies#leave'
  
  match '/joingame', :to => 'pawns#new'
  match '/mygames', :to => 'gamestates#mygames'
  
  match '/update', :to => 'updaters#update'
  
  root :to => 'pages#home'
end
