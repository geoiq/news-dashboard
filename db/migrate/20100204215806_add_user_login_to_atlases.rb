class AddUserLoginToAtlases < ActiveRecord::Migration
  def self.up
    add_column :atlases, :user_login, :string
    add_index :atlases, :user_login
  end

  def self.down
    remove_index :atlases, :user_login
    remove_column :atlases, :user_login
  end
end
