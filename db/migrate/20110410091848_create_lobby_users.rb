class CreateLobbyUsers < ActiveRecord::Migration
  def self.up
    create_table :lobby_users do |t|
      t.integer :user_id
      t.integer :lobby_id

      t.timestamps
    end
  end

  def self.down
    drop_table :lobby_users
  end
end
