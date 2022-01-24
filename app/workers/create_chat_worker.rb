class CreateChatWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(application_id, chat_number)
    Chat.create(number: chat_number, application_id: application_id)
  end
end
