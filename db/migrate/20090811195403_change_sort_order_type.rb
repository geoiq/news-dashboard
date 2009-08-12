class ChangeSortOrderType < ActiveRecord::Migration
  def self.up
    change_column(:map_lists, :sort_order, :integer, :default => 999)
  end

  def self.down
    change_column(:map_lists, :sort_order, :string)
  end
end
