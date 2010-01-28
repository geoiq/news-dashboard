class CreateFooters < ActiveRecord::Migration
  def self.up
    create_table :footers do |t|
      t.text :link
      t.text :linktext
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :footers
  end
end
