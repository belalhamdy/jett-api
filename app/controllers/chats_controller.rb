class ChatsController < ApplicationController
  before_action :set_application, only: %i[show update create]
  before_action :set_chat, only: %i[show update]
  before_action :set_chats, only: %i[create]

  def index
    returned_chats = Chat.all.as_json(except: %i[id application_id])
    render json: { body: returned_chats, message: format('Retrieved %i chats.', returned_chats.length) }, status: :ok
  end

  def show
    returned_chat = chat.as_json(except: %i[id application_id])
    render json: { body: returned_chat, message: format('Retrieved chat %i.', @chat.number) }, status: :ok
  end

  def create
    chat = Chat.new
    chat.application_id = @application.id
    ActiveRecord::Base.transaction do
      @application.lock!
      last_chat = @chats.last
      chat.number = last_chat.nil? ? 1 : last_chat.number + 1
      @application[:chats_count] += 1
      @application.save
    end
    unless chat.number.nil?
      if chat.save
        render json: { body: { chat_number: chat.number },
                       message: format('Chat %i is created successfully.', chat.number) }, status: :ok
      else
        render json: { body: { chat_number: nil },
                       message: 'Cannot create chat.' }, status: :bad_request
      end
    end
  end

  private

  def set_application
    @application = Application.where(token: params[:application_token]).first
    render json: { body: nil, message: 'Token does not belong to any application.' }, status: :bad_request if @application.nil?
  end

  def set_chat
    @chat = Chat.where(application_id: @application.id, number: params[:chat_number])
  end

  def set_chats
    @chats = Chat.where(application_id: @application.id)
  end

end
