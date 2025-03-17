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

ActiveRecord::Schema[8.0].define(version: 2025_03_17_182940) do
  create_table "admin_users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
  end

  create_table "details", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "device_id"
    t.string "device_name"
    t.string "model"
    t.string "ignition"
    t.string "rele_state"
    t.string "last_event_type"
    t.string "last_user"
    t.datetime "last_rele_modified"
    t.string "url"
    t.string "velo_max"
    t.string "battery"
    t.string "bat_bck"
    t.string "horimetro"
    t.string "odometro"
    t.string "cercas"
    t.string "satelites"
    t.string "version"
    t.string "imei"
    t.string "bat_nivel"
    t.string "signal_gps"
    t.string "signal_gsm"
    t.string "acc"
    t.string "acc_virtual"
    t.string "charge"
    t.string "heartbeat"
    t.text "obs"
    t.text "status"
    t.text "network"
    t.text "params"
    t.string "apn"
    t.string "ip_and_port"
    t.boolean "alert_whatsApp", default: false
    t.boolean "alert_telegram", default: false
    t.boolean "alert_email", default: false
    t.boolean "send_exit_cerca", default: false
    t.boolean "send_battery", default: false
    t.boolean "send_velo_max", default: false
    t.boolean "send_rele", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "car_id"
    t.string "car_name"
    t.string "driver_id"
    t.string "driver_name"
    t.string "event_type"
    t.string "event_name"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "phone", null: false
    t.boolean "active", default: false, null: false
    t.boolean "admin", default: false, null: false
    t.text "cars"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "sessions", "users"
end
