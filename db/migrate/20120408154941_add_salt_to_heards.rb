class AddSaltToHeards < ActiveRecord::Migration
  def self.up
  	add_column :heards, :salt, :integer
  end

  def self.down
  	remove_column :heards, :salt
  end
end
