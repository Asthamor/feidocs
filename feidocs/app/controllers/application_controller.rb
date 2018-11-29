class ApplicationController < ActionController::Base
    before_action :authenticate_professor!
    protect_from_forgery with: :exception
end
