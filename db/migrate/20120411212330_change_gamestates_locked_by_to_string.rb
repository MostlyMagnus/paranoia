class ChangeGamestatesLockedByToString < ActiveRecord::Migration
  def self.up
  	change_column :gamestates, :locked_by, :string, :default => "nil"
  end

  def self.down
  	change_column :gamestates, :locked_by, :integer
  end
end
