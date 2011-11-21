class CreateSnapshots < ActiveRecord::Migration
  def self.up
    create_table :snapshots do |t|
      t.integer :gamestate_id
      t.integer :turn
      t.integer :tick
      t.string :actions

      t.timestamps
    end
  end

  def self.down
    drop_table :snapshots
  end
end
