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

ActiveRecord::Schema[7.2].define(version: 2025_08_01_040758) do
  create_table "readings", force: :cascade do |t|
    t.string "question", null: false
    t.string "spread_type"
    t.text "cards_drawn"
    t.text "claude_interpretation"
    t.text "claude_advice"
    t.string "querent_name"
    t.datetime "performed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["performed_at"], name: "index_readings_on_performed_at"
    t.index ["spread_type"], name: "index_readings_on_spread_type"
  end

  create_table "tarot_cards", force: :cascade do |t|
    t.string "name", null: false
    t.string "arcana", null: false
    t.string "suit"
    t.integer "number"
    t.text "upright_meaning"
    t.text "reversed_meaning"
    t.text "keywords"
    t.string "element"
    t.string "astrological_sign"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arcana"], name: "index_tarot_cards_on_arcana"
    t.index ["name"], name: "index_tarot_cards_on_name", unique: true
    t.index ["suit", "number"], name: "index_tarot_cards_on_suit_and_number"
  end
end
