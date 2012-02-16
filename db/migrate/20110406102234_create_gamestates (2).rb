class CreateGamestates < ActiveRecord::Migration
  def self.up
    create_table :gamestates do |t|
      t.integer :ship_id
      t.string :nodestatus
      t.string :playerstatus
      t.string :playerlocations
      t.integer :timescale

      t.timestamps
    end
  end

  def self.down
    drop_table :gamestates
  end
end
