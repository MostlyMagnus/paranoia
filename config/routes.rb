Paranoia::Application.routes.draw do  
  resources :users
  resources :pawns
  resources :sessions, :only => [:new, :create, :destroy]
  resources :updaters
  resources :gamestates do
    member do
      get :join
    end
  end
  
  match '/signup',  :to => 'users#new'

  match '/contact', :to => 'pages#contact'
  match '/about',   :to => 'pages#about'
  match '/help',    :to => 'pages#help'
  
  match '/signin',  :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'

  match '/joingame', :to => 'pawns#new'
  match '/mygames', :to => 'pages#home'
  
  match '/update', :to => 'updaters#update'
  
  root :to => 'pages#home'
end
