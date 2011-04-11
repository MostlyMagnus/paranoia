class CreateShips < ActiveRecord::Migration
  def self.up
    create_table :ships do |t|
      t.string :name
      t.string :description
      t.string :image
      t.string :layout

      t.timestamps
    end
  end

  def self.down
    drop_table :ships
  end
end
