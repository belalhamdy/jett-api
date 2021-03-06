class CreateApplications < ActiveRecord::Migration[5.2]
  def change
    create_table :all_applications do |t|
      t.string :name, null: false
      t.string :token, null: false, index: true, unique: true
      t.integer :chats_count, default: 0
      t.timestamps
    end
  end
end
