Paranoia::Application.routes.draw do  
  resources :users
  resources :sessions, :only => [:new, :create, :destroy]
  
  match '/signup',  :to => 'users#new'

  match '/contact', :to => 'pages#contact'
  match '/about',   :to => 'pages#about'
  match '/help',    :to => 'pages#help'
  
  match '/signin',  :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'

  root :to => 'pages#home'
end
