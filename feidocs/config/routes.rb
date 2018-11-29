Rails.application.routes.draw do

  devise_for :professors
  resources :documents

  root 'inicio#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

end
