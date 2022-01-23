class ApplicationsController < ApplicationController
  before_action :set_application, only: %i[show update]

  # GET API/Applications
  def index
    @all_applications = Application.all
    @json_applications = @all_applications.as_json(except: :id)
    render json: { body: @json_applications, message: format('Retrieved %i applications.', @json_applications.length) },
           status: :ok
  end

  def show
    @return_application = @application.first
    render json: { body: @return_application.as_json(except: :id), message: format('Retrieved the application %s.', @return_application.name) },
           status: :ok
  end

  def create
    @application = Application.new(application_params)
    @application.token = SecureRandom.hex(16)
    if @application.save
      render json: { body: { token: @application.token },
                     message: format('Created application with id %s.', @application.id) },
             status: :ok
    else
      render json: @application.errors, status: :bad_request
    end
  end

  def update
    @prev_name = @application.name
    if @application.update(application_params)
      render json: { body: @application.as_json(except: :id),
                     message: format('Application with name %s is updated to %s successfully.', @prev_name, @application.name) },
             status: :ok
    else
      render json: @application.errors, status: :bad_request
    end

  end

  def self.update_chats_count
    @non_empty_applications = Chat.group(:application_id).count
    Application.all.each do |application|
      application.chats_count = @non_empty_applications[application.id] || 0
      application.save
    end
  end

  private

  def set_application
    @application = Application.where(token: params[:token])
  end

  def application_params
    params.require(:application).permit(:name)
  end

end
