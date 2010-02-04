class CreateConfigurations < ActiveRecord::Migration
  def self.up
    create_table :configurations do |t|
      t.string :header_color
      t.string :logo_image_file_name
      t.string :intro_image_file_name
    end
  end

  def self.down
    drop_table :configurations
  end
end
