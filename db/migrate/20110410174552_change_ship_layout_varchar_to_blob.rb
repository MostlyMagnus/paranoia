class ChangeShipLayoutVarcharToBlob < ActiveRecord::Migration
  def self.up
    change_table :ships do |t|
      t.change :layout, :text
    end
  end

  def self.down
    change_table :ships do |t|
      t.change :layout, :varchar
    end
  end
end
