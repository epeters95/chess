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

ActiveRecord::Schema[7.0].define(version: 2024_04_27_050203) do
  create_table "boards", force: :cascade do |t|
    t.string "turn"
    t.string "status_str", default: ""
    t.integer "move_count", default: 0
    t.text "positions_array"
    t.integer "game_id", null: false
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
    t.integer "board_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "notation"
    t.index ["board_id"], name: "index_moves_on_board_id"
  end

  add_foreign_key "boards", "games"
  add_foreign_key "moves", "boards"
end
