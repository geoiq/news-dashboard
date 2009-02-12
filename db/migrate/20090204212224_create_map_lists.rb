class CreateMapLists < ActiveRecord::Migration
  def self.up
    create_table :map_lists do |t|
      t.integer :atlas_id
      t.string :title
      t.text :description
      t.string :maker_tag
      t.string :maker_user
      t.text :sort_order

      t.timestamps
    end
  end

  def self.down
    drop_table :map_lists
  end
end
