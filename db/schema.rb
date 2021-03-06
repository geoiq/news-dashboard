# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100211200956) do

  create_table "atlases", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.string   "url"
    t.boolean  "listed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_login"
  end

  add_index "atlases", ["user_login"], :name => "index_atlases_on_user_login"

  create_table "blurbs", :force => true do |t|
    t.string   "key"
    t.string   "title"
    t.text     "body"
    t.datetime "publish_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "configurations", :force => true do |t|
    t.string "header_color"
    t.string "logo_image_file_name"
    t.string "intro_image_file_name"
  end

  create_table "map_lists", :force => true do |t|
    t.integer  "atlas_id"
    t.string   "title"
    t.text     "description"
    t.string   "maker_tag"
    t.string   "maker_user"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_order",      :default => 999
    t.string   "maps_sort_order"
    t.boolean  "default",         :default => false
    t.integer  "default_map_id"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
