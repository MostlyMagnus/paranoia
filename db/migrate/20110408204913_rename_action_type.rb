class RenameActionType < ActiveRecord::Migration
  def self.up
    rename_column :actions, :type, :action_type
  end

  def self.down
    rename_column :actions, :action_type, :type
  end
end
