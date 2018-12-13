Rails.application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'
  devise_for :professors

  get 'documents/upload' => 'documents#upload'
  post 'documents/upload' => 'documents#after_upload', as: :after_upload

  resources :documents

  root 'documents#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

end
