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

ActiveRecord::Schema[8.0].define(version: 2025_09_26_155738) do
  create_table "action_mailbox_inbound_emails", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.string "message_id", null: false
    t.string "message_checksum", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "message_checksum"], name: "index_action_mailbox_inbound_emails_uniqueness", unique: true
  end

  create_table "action_text_rich_texts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "body", size: :long
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
  end

  create_table "batteries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "device_id"
    t.string "device_name"
    t.string "user_id"
    t.string "user_name"
    t.decimal "bat", precision: 5, scale: 2
    t.decimal "bkp", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "check_lists", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "user_id"
    t.string "detail_id"
    t.string "type"
    t.boolean "freios", default: false
    t.boolean "luzes", default: false
    t.boolean "pneus", default: false
    t.boolean "estepe", default: false
    t.boolean "oleo", default: false
    t.boolean "buzina", default: false
    t.boolean "painel", default: false
    t.boolean "doc", default: false
    t.boolean "retrovisor", default: false
    t.boolean "parabrisa", default: false
    t.boolean "limpador", default: false
    t.boolean "macaco", default: false
    t.boolean "lataria", default: false
    t.text "obs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "commands", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "type_device"
    t.string "name"
    t.string "command"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "command_sms"
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
    t.boolean "send_moving", default: false
    t.string "iccid"
    t.string "category"
    t.string "cell_number"
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

  create_table "notifications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "whatsapp"
    t.text "email"
    t.text "telegram"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_id"
  end

  create_table "push_notifications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "push_subscriptions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "endpoint"
    t.string "p256dh"
    t.string "auth"
    t.boolean "subscribed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["endpoint"], name: "index_push_subscriptions_on_endpoint", unique: true
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
    t.string "email_address"
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "phone", null: false
    t.boolean "active", default: false, null: false
    t.boolean "admin", default: false, null: false
    t.text "cars"
    t.datetime "password_reset_sent_at"
    t.boolean "maintenance", default: false
    t.string "cpf"
    t.boolean "pessoal", default: false, null: false
    t.boolean "view_only", default: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "sessions", "users"
end
