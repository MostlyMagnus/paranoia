class AddUpdateWhenToGamestate < ActiveRecord::Migration
  def self.up
    add_column :gamestates, :update_when, :datetime    
  end

  def self.down
    remove_column :gamestates, :update_when
  end
end
