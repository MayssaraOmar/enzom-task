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

ActiveRecord::Schema[7.0].define(version: 2022_12_22_122510) do
  create_table "countries", charset: "latin1", force: :cascade do |t|
    t.string "name", limit: 300, null: false
    t.string "code", limit: 50, null: false
    t.string "iso3", limit: 50, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_countries_on_name"
  end

  create_table "populations", charset: "latin1", force: :cascade do |t|
    t.integer "country_id", null: false
    t.integer "year", null: false
    t.bigint "count", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_populations_on_country_id"
    t.index ["year"], name: "index_populations_on_year"
  end

end
