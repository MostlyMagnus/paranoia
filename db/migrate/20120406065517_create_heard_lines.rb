class CreateHeardLines < ActiveRecord::Migration
  def self.up
    create_table :heard_lines do |t|
      t.integer :pawn_id
      t.integer :line_id
      t.integer :scramble

      t.timestamps
    end
    add_index :heard_lines, :pawn_id
    add_index :heard_lines, :line_id
    add_index :heard_lines, [:pawn_id, :line_id], :unique => true
  end

  def self.down
    drop_table :heard_lines
  end
end
