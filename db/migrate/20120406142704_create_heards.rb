class CreateHeards < ActiveRecord::Migration
  def self.up
    create_table :heards do |t|
      t.integer :pawn_id
      t.integer :line_id
      t.integer :scramble

      t.timestamps
    end
  end

  def self.down
    drop_table :heards
  end
end
