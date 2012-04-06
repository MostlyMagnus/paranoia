# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120406142704) do

  create_table "actions", :force => true do |t|
    t.integer  "pawn_id"
    t.integer  "queue_number"
    t.integer  "action_type"
    t.string   "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_inputs", :force => true do |t|
    t.integer  "user_event_id"
    t.integer  "pawn_id"
    t.string   "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gamestates", :force => true do |t|
    t.integer  "ship_id"
    t.string   "nodestatus"
    t.string   "playerstatus"
    t.float    "timescale"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "update_when"
  end

  create_table "heards", :force => true do |t|
    t.integer  "pawn_id"
    t.integer  "line_id"
    t.integer  "scramble"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lines", :force => true do |t|
    t.integer  "pawn_id"
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lobbies", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "min_slots"
    t.integer  "max_slots"
    t.integer  "has_password"
    t.string   "password"
    t.integer  "ship_id"
    t.integer  "created_by_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "game_speed"
  end

  create_table "lobby_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "lobby_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "log_entries", :force => true do |t|
    t.integer  "gamestate_id"
    t.integer  "turn"
    t.string   "entry"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", :force => true do |t|
    t.integer  "pawn_id"
    t.integer  "action_type"
    t.string   "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pawns", :force => true do |t|
    t.integer  "user_id"
    t.integer  "gamestate_id"
    t.integer  "persona_id"
    t.integer  "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "personas", :force => true do |t|
    t.string   "name"
    t.integer  "profession"
    t.string   "bio"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ships", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "image"
    t.string   "layout",      :limit => nil
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "snapshots", :force => true do |t|
    t.integer  "gamestate_id"
    t.integer  "turn"
    t.integer  "tick"
    t.string   "actions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_events", :force => true do |t|
    t.integer  "action_type"
    t.integer  "gamestate_id"
    t.integer  "lifespan"
    t.string   "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password"
    t.string   "salt"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
