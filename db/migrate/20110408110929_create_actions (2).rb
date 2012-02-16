class CreateActions < ActiveRecord::Migration
  def self.up
    create_table :actions do |t|
      t.integer :pawn_id
      t.integer :queue_number
      t.integer :type
      t.string :params

      t.timestamps
    end
  end

  def self.down
    drop_table :actions
  end
end
