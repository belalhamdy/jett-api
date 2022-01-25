class MessagesController < ApplicationController
  before_action :set_chat, only: %i[index search]
  before_action :set_message, only: %i[show update]

  def index
    messages = Message.where(chat_id: @chat.id)
    json_messages = messages.as_json(except: %i[id application_id chat_id])
    render json: { body: json_messages, message: format('fetched %i messages.', messages.length) }, status: :ok
  end

  def show
    render json: { data: @message.as_json(except: %i[id application_id chat_id]), error: '' }, status: :ok
  end

  def create
    begin
      if !message_params[:body].blank?
        set_parameters
        if (@application && @chat)
          @message = Message.where(chat_id: @chat.id, application_id: @application.id).last
          @message_number = @message ? @message.number + 1 : 1
          CreateMessageWorker.perform_async(message_params[:body], @application.id, @chat.id, @message_number)
          render json: { data: { number: @message_number }, error: '' }, status: :created
        end
      else
        render json: { data: nil, error: 'Body is required' }, status: :bad_request
      end
    rescue Exception => ex
      render json: { data: nil, error: ex.message }, status: :internal_server_error
    end
  end

  def update
    begin
      if !message_params[:body].blank?
        UpdateMessageWorker.perform_async(message_params[:body], @message.id) if @application && @chat && @message
        @message.body = message_params[:body]
        render json: { data: @message.as_json(except: %i[id application_id chat_id]), error: '' }, status: :ok
      else
        render json: { data: nil, error: 'Body is required' }, status: :bad_request
      end
    rescue Exception => ex
      render json: { data: nil, error: ex.message }, status: :internal_server_error
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

  def message_params
    params.require(:message).permit(:body)
  end

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
    @message = @chat.messages.where(number: params[:number]).first if @chat
  end
end
