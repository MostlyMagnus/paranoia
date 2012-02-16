class RemovePlayerlocationsFromGamestate < ActiveRecord::Migration
  def self.up
    remove_column :gamestates, :playerlocations
  end

  def self.down
    add_column :gamestates, :playerlocations, :string
  end
end
