class ChangeSortOrderType < ActiveRecord::Migration
  def self.up
    remove_column :map_lists, :sort_order
    add_column    :map_lists, :sort_order, :integer, :default => 999
  end

  def self.down
    remove_column :map_lists, :sort_order
    add_column    :map_lists, :sort_order, :string
  end
end
