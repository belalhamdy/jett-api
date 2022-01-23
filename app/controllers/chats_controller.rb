class ChatsController < ApplicationController
  before_action :set_application, only: %i[show update create]
  before_action :set_chat, only: %i[show update]

  private

  def set_application
    @application = Application.where(token: params[:application_token])
    render json: { body: nil, message: 'Token does not belong to any application.' }, status: :bad_request if @application.nil?
  end

  def set_chat
    @chat = Chat.where(application_id: @application.id, number: params[:number])
  end

end
