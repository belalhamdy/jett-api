class Chat < ApplicationRecord
  belongs_to :application

  has_many :messages, dependent: :nullify # keep the records but with null foreign key.
end
