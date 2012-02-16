class CreatePawns < ActiveRecord::Migration
  def self.up
    create_table :pawns do |t|
      t.integer :user_id
      t.integer :gamestate_id
      t.integer :persona_id
      t.integer :role
      t.string :action_queue

      t.timestamps
    end
  end

  def self.down
    drop_table :pawns
  end
end
