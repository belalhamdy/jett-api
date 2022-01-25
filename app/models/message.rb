class Message < ApplicationRecord
  belongs_to :chat
  has_one :application, through: :chat
  validates :number, :chat, presence: true

end
