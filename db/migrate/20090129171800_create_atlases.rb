class CreateAtlases < ActiveRecord::Migration
  def self.up
    create_table :atlases do |t|
      t.integer :user_id
      t.string :title
      t.text :description
      t.string :url
      t.boolean :listed

      t.timestamps
    end
  end

  def self.down
    drop_table :atlases
  end
end
