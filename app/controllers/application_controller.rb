class ApplicationController < ActionController::Base
    before_action :authenticate_professor!
    protect_from_forgery with: :exception

    before_action :configure_permitted_parameters, if: :devise_controller?

    protected

    def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:fullName, :personalNumber, :email, :password, :remember_me])
        devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password, :remember_me])
        devise_parameter_sanitizer.permit(:account_update, keys: [:fullName, :personalNumber, :photo, :email, :password, :remember_me])
    end


end
