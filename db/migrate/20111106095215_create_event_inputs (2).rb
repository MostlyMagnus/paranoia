class CreateEventInputs < ActiveRecord::Migration
  def self.up
    create_table :event_inputs do |t|
      t.integer :user_event_id
      t.integer :pawn_id
      t.string :params

      t.timestamps
    end
  end

  def self.down
    drop_table :event_inputs
  end
end
