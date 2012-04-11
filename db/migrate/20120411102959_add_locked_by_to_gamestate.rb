class AddLockedByToGamestate < ActiveRecord::Migration
  def self.up
    add_column :gamestates, :locked_by, :integer
  end

  def self.down
    remove_column :gamestates, :locked_by
  end
end
