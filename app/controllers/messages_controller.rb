class MessagesController < ApplicationController
  before_action :set_messages, only: %i[index search create]
  before_action :set_message, only: %i[show update]

  def index
    json_messages = @messages.as_json(except: %i[id application_id chat_id])
    render json: { body: json_messages, message: format('fetched %i messages.', @messages.length) }, status: :ok
  end

  def show
    render json: { data: @message.as_json(except: %i[id application_id chat_id]), error: '' }, status: :ok
  end

  def create
    @message = Message.new(message_params)
    @message.chat_id = @chat.id
    ActiveRecord::Base.transaction do
      @chat.lock!
      last_message = @messages.last
      @message.number = last_message.nil? ? 1 : last_message.number + 1
      @chat[:messages_count] += 1
      @chat.save
    end
    unless @message.number.nil?
      if @message.save
        render json: { body: { message_number: @message.number },
                       message: format('Message %i is created successfully.', @message.number) }, status: :ok
      else
        render json: { body: { message_number: nil },
                       message: 'Cannot create message.' }, status: :bad_request
      end
    end
  end

  def search
    # if @@first_search
    #   @@first_search = false
    #   Message.reindex
    # end
    # @messages = Message.search(params[:body], where: { chat_id: @chat.id, application_id: @application.id })
    # render json: { data: @messages.as_json(:except => [:id, :application_id, :chat_id]), error: '' }, status: :ok
  end

  private

  def set_application
    @application = Application.where(token: params[:application_token]).first
    return if @application

    render json: { body: nil, message: 'Token does not belong to any application.' }, status: :bad_request
  end

  def set_chat
    set_application
    return if @application.nil?

    @chat = @application.chats.where(number: params[:chat_number]).first
    return if @chat

    render json: { body: nil, message: format('Application %s does not contain the given chat number %i.',
                                              @application.token, params[:chat_number]) }, status: :bad_request
  end

  def set_message
    set_chat
    return if @chat.nil?

    @message = @chat.messages.where(number: params[:message_number]).first if @chat
  end

  def set_messages
    set_chat
    return if @chat.nil?
    @messages = @chat.messages if @chat
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
