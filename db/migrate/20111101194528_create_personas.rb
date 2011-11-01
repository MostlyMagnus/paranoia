class CreatePersonas < ActiveRecord::Migration
  def self.up
    create_table :personas do |t|
      t.string :name
      t.integer :profession
      t.string :bio

      t.timestamps
    end
  end

  def self.down
    drop_table :personas
  end
end
