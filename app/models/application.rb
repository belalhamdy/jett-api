class Application < ApplicationRecord
  validates :token, presence: true, uniqueness: true # unique is better than distinct
  validates :name, presence: true

  has_many :chats, dependent: :nullify # keep the records but with null foreign key.
  has_many :messages, through: :chats, source: :messages
end
