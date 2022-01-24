class ChatsController < ApplicationController
  before_action :set_application, only: %i[show update create]
  before_action :set_chat, only: %i[show update]
  before_action :set_chats, only: %i[create]
  #TODO remove @ from variables and try
  def index
    @returned_chats = Chat.all.as_json(except: %i[id application_id])
    render json: { body: @returned_chats, message: format('Retrieved %i chats.', @returned_chats.length) }, status: :ok
  end
  # account = Account.first
  # account.with_lock do
  #   # This block is called within a transaction,
  #   # account is already locked.
  #   account.balance -= 100
  #   account.save!
  # end
  def show
    @returned_chat = @chat.as_json(except: %i[id application_id])
    render json: { body: @returned_chat, message: format('Retrieved chat %i.', @chat.number) }, status: :ok
  end

  def create
    @last_chat = @chats.last
    @chat_number = @last_chat ? @last_chat.number + 1 : 1
    CreateChatWorker.perform_async(@application.id, @chat_number)
    render json: { data: { number: @chat_number }, error: '' }, status: :created
  end

  def self.update_messages_count
    @chats_counts = Message.group(:chat_id).count
    Chat.all.each do |chat|
      chat.messages_count = @chats_counts[chat.id] || 0
      chat.save
    end
  end

  private

  def set_application
    @application = Application.where(token: params[:application_token]).first
    render json: { body: nil, message: 'Token does not belong to any application.' }, status: :bad_request if @application.nil?
  end

  def set_chat
    @chat = Chat.where(application_id: @application.id, number: params[:number])
  end

  def set_chats
    @chats = Chat.where(application_id: @application.id)
  end

end
