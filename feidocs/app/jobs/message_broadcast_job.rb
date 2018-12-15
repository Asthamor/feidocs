class MessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(message)
    sender = message.professor
    recipient = message.conversation.opposed_user(sender)

    broadcast_to_sender(sender, message)
    broadcast_to_recipient(recipient, message)
  end

  private

  def broadcast_to_sender(professor, message)
    ActionCable.server.broadcast(
        "conversations-#{professor.id}",
        message: render_message(message, professor),
        conversation_id: message.conversation_id
    )
  end

  def broadcast_to_recipient(professor, message)
    ActionCable.server.broadcast(
        "conversations-#{professor.id}",
        window: render_window(message.conversation, professor),
        message: render_message(message, professor),
        conversation_id: message.conversation_id
    )
  end

  def render_message(message, professor)
    ApplicationController.render(
        partial: 'messages/message',
        locals: {message: message, professor: professor }
    )
  end

  def render_window(conversation, professor)
    ApplicationController.render(
        partial: 'conversations/conversation',
        locals: {conversation: conversation, professor: professor }
    )
  end
end
