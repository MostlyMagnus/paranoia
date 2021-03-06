Paranoia::Application.routes.draw do  
  resources :users
  resources :pawns
  resources :sessions, :only => [:new, :create, :destroy]
  resources :updaters
  resources :lobbies, :path_names => { :edit => 'leave' }
    
  resources :lobbies do
    member do
      get :leave
    end
  end
  
  resources :gamestates do
    member do      
      #get :create
      get :wip_show
      
      get :json_gamestate
      
      get :add_action
      get :remove_action

      get :add_text
      get :get_text

      get :get_logs
            
      get :node_use  
    end
  end
  
  #match '/tempIndex', :to => 'pages#tempIndex'
  
  match '/signup',  :to => 'users#new'

  #match '/contact', :to => 'pages#contact'
  #match '/about',   :to => 'pages#about'
  #match '/help',    :to => 'pages#help'
  
  match '/signin',  :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'

  #match '/lobbies', :to => 'lobbies#index'
  
  #match '/joingame', :to => 'pawns#new'
 # match '/mygames', :to => 'gamestates#mygames'
  #match '/creategame', :to => 'gamestates#create'
  
  #match '/update', :to => 'updaters#update'
  
	root :to => 'pages#home'
end
