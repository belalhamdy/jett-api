class MessagesController < ApplicationController
  def index
    @messages = Message.where(chat_id: @chat.id, application_id: @application.id).as_json(:except => [:id, :application_id, :chat_id])
    render json: {data: @messages, error: ''}, status: :ok
  end
end
