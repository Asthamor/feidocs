Rails.application.routes.draw do

  get 'chat/index'
  resources :conversations, only: [:create] do
    member do
      post :close
    end

    resources :messages, only: [:create]
  end
  mount Ckeditor::Engine => '/ckeditor'
  devise_for :professors

  get 'documents/upload' => 'documents#upload', as: :upload_document
  post 'documents/upload' => 'documents#after_upload', as: :after_upload
  get 'documents/rename' => 'documents#rename', as: :rename
  patch 'documents/rename' => 'documents#rename_upload', as: :rename_upload
  post 'documents/document_professor' => 'documents#document_professor', as: :document_professor
  patch 'documents/document_professor_upload' => 'documents#document_professor_upload', as: :document_professor_upload
  get 'documents/shared' => 'documents#shared', as: :documents_shared

  resources :documents

  root 'documents#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

end
