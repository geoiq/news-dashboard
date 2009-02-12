class CreateBlurbs < ActiveRecord::Migration
  def self.up
    create_table :blurbs do |t|
      t.string "key"
      t.string "title"
      t.text "body"
      t.datetime "publish_at"
      t.timestamps
    end
  end

  def self.down
    drop_table :blurbs
  end
end
