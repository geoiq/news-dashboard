class RemoveFooters < ActiveRecord::Migration
  def self.up
    drop_table :footers
  end

  def self.down
    create_table :footers do |t|
      t.text :link
      t.text :linktext
      t.text :description
      t.timestamps
    end
  end
end
