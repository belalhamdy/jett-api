class Chat < ApplicationRecord
  belongs_to :application
  validates :number, uniqueness: true

  has_many :messages, dependent: :nullify # keep the records but with null foreign key.
end
