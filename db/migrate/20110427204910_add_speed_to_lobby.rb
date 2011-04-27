class AddSpeedToLobby < ActiveRecord::Migration
  def self.up
    add_column :lobbies, :game_speed, :integer
  end

  def self.down
    remove_column :lobbies, :game_speed
  end
end
