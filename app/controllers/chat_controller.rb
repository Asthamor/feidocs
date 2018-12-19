class ChatController < ApplicationController
  before_action :authenticate_professor!
  def index
    session[:conversations] ||= []

    @professors = Professor.all.where.not(id: current_professor)
    @conversations = Conversation.includes(:recipient, :messages)
                         .find(session[:conversations])
  end
end
