class AddDefaultMapId < ActiveRecord::Migration
  def self.up
    add_column :map_lists, :default_map_id, :integer
  end

  def self.down
    remove_column :map_lists, :default_map_id
  end
end
