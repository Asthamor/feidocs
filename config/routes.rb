Rails.application.routes.draw do
  root 'inicio#index'

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
  get 'documents/export' => 'documents#convert', as: :convert
  post 'documents/upload' => 'documents#after_upload', as: :after_upload
  post 'documents/document_professor' => 'documents#document_professor', as: :document_professor
  patch 'documents/document_professor_upload' => 'documents#document_professor_upload', as: :document_professor_upload
  get 'documents/allshared' => 'documents#allshared', as: :documents_shared
  get 'documents/shared/:id' => 'documents#shared', as: :document_shared
  get 'signatures/download' => 'signatures#download', as: :download_signature
  get 'documents/sign' => 'documents#sign', as: :sign_document
  patch 'documents/sign' => 'documents#after_sign', as: :after_sign_document
  get 'documents/validate' => 'documents#validate', as: :validate_document
  #get 'chat/index' => 'chat#index', as: :chat_index



  resources :documents
  resources :signatures, only: [:new, :create]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

end
