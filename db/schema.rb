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

ActiveRecord::Schema[7.0].define(version: 2023_03_21_122716) do
  create_table "order_items", force: :cascade do |t|
    t.integer "order_id"
    t.integer "quantity"
    t.string "sku"
    t.decimal "selling_price"
    t.integer "selling_price_currency"
    t.decimal "weight"
    t.string "description"
    t.string "country_alpha2"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "sender_name"
    t.string "sender_contact"
    t.string "sender_address_line1"
    t.string "sender_address_city"
    t.string "sender_address_state"
    t.string "sender_address_postal_code"
    t.string "sender_address_country_alpha2"
    t.string "receiver_name"
    t.string "receiver_contact"
    t.string "receiver_address_line1"
    t.string "receiver_address_city"
    t.string "receiver_address_state"
    t.string "receiver_address_postal_code"
    t.string "receiver_address_country_alpha2"
    t.string "receiver_email"
    t.string "directlink_info"
    t.decimal "shipping_fee"
    t.decimal "parcel_length"
    t.decimal "parcel_width"
    t.decimal "parcel_height"
    t.decimal "parcel_weight"
    t.string "parcel_content"
    t.integer "order_items_size"
    t.string "tracking_number"
    t.string "tracking_url"
    t.string "ship_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
