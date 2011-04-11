class CreateLobbies < ActiveRecord::Migration
  def self.up
    create_table :lobbies do |t|
      t.string :name
      t.string :description
      t.integer :min_slots
      t.integer :max_slots
      t.integer :has_password
      t.string :password
      t.integer :ship_id
      t.integer :created_by_user_id
      t.timestamp :created_at

      t.timestamps
    end
  end

  def self.down
    drop_table :lobbies
  end
end
