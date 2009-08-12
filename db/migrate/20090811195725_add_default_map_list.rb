class AddDefaultMapList < ActiveRecord::Migration
  def self.up
    add_column :map_lists, :default, :boolean, :default => false
  end

  def self.down
    remove_column :map_lists, :default
  end
end
