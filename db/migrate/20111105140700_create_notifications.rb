class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.integer :pawn_id
      t.integer :action_type
      t.string :params

      t.timestamps
    end
  end

  def self.down
    drop_table :notifications
  end
end
