class CreateLines < ActiveRecord::Migration
  def self.up
    create_table :lines do |t|
      t.integer :line_id
      t.integer :pawn_id
      t.integer :gamestate_id
      t.string :text

      t.timestamps
    end
  end

  def self.down
    drop_table :lines
  end
end
