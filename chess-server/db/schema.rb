# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_07_10_064636) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authentication_tokens", force: :cascade do |t|
    t.string "body"
    t.bigint "user_id", null: false
    t.datetime "last_used_at"
    t.integer "expires_in"
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["body"], name: "index_authentication_tokens_on_body"
    t.index ["user_id"], name: "index_authentication_tokens_on_user_id"
  end

  create_table "boards", force: :cascade do |t|
    t.string "turn"
    t.string "status_str", default: ""
    t.integer "move_count", default: 0
    t.text "positions_array"
    t.bigint "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_boards_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "white_name"
    t.string "black_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.bigint "black_id"
    t.integer "white_id", default: 0, null: false
    t.index ["black_id"], name: "index_games_on_black_id"
    t.index ["white_id"], name: "index_games_on_white_id"
  end

  create_table "live_games", force: :cascade do |t|
    t.string "white_token", default: ""
    t.string "black_token", default: ""
    t.string "access_code", default: ""
    t.bigint "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_live_games_on_game_id"
  end

  create_table "moves", force: :cascade do |t|
    t.string "piece_str", null: false
    t.string "other_piece_str"
    t.string "move_type", null: false
    t.string "new_position", null: false
    t.string "rook_position"
    t.boolean "completed", default: false
    t.string "promotion_choice"
    t.integer "move_count"
    t.bigint "board_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "notation"
    t.string "position", default: ""
    t.index ["board_id"], name: "index_moves_on_board_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.string "active_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_players_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "username", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "authentication_tokens", "users"
  add_foreign_key "boards", "games"
  add_foreign_key "games", "players", column: "black_id"
  add_foreign_key "live_games", "games"
  add_foreign_key "moves", "boards"
end
