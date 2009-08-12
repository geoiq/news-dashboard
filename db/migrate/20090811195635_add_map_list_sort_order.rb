class AddMapListSortOrder < ActiveRecord::Migration
  def self.up
    add_column :map_lists, :maps_sort_order, :string
  end

  def self.down
    remove_column :map_lists, :maps_sort_order
  end
end
