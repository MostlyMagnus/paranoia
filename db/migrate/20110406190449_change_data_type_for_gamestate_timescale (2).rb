class ChangeDataTypeForGamestateTimescale < ActiveRecord::Migration
  def self.up
    change_table :gamestates do |t|
      t.change :timescale, :float
    end    
  end

  def self.down
  end
end
