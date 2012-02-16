class CreateLogEntries < ActiveRecord::Migration
  def self.up
    create_table :log_entries do |t|
      t.integer :gamestate_id
      t.integer :turn
      t.string :entry

      t.timestamps
    end
  end

  def self.down
    drop_table :log_entries
  end
end
