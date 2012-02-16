class ChangeShipBlobBackToVarchar < ActiveRecord::Migration
  def self.up
    change_table :ships do |t|
      t.change :layout, :varchar
    end
  end

  def self.down
    change_table :ships do |t|
      t.change :layout, :blob
    end
  end
end
