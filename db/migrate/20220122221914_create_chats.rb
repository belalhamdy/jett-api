class CreateChats < ActiveRecord::Migration[5.2]
  def change
    create_table :chats do |t|
      t.integer :number, null: false, index: true, unique: true
      t.integer :messages_count, default: 0
      t.references :application, foreign_key: true
      t.timestamps
    end
  end
end
