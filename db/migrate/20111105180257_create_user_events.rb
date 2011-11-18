class CreateUserEvents < ActiveRecord::Migration
  def self.up
    create_table :user_events do |t|
      t.integer :action_type
      t.integer :gamestate_id
      t.integer :lifespan
      t.string :params

      t.timestamps
    end
  end

  def self.down
    drop_table :user_events
  end
end
