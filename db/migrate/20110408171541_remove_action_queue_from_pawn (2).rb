class RemoveActionQueueFromPawn < ActiveRecord::Migration
  def self.up
    remove_column :pawns, :action_queue
  end

  def self.down
    add_column :pawns, :action_queue, :string
  end
end
