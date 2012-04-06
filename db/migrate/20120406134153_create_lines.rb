class CreateLines < ActiveRecord::Migration
  def self.up
    create_table :lines do |t|
      t.integer :pawn_id
      t.string :text

      t.timestamps
    end
  end

  def self.down
    drop_table :lines
  end
end
