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

ActiveRecord::Schema.define(version: 2020_10_28_212318) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "street"
    t.string "street2"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.float "latitude"
    t.float "longitude"
    t.integer "addressable_id"
    t.string "addressable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "county"
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable_type_and_addressable_id"
  end

  create_table "age_ranges", force: :cascade do |t|
    t.integer "min", null: false
    t.integer "max", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "age_ranges_needs", id: false, force: :cascade do |t|
    t.bigint "age_range_id", null: false
    t.bigint "need_id", null: false
  end

  create_table "age_ranges_users", id: false, force: :cascade do |t|
    t.bigint "age_range_id", null: false
    t.bigint "user_id", null: false
  end

  create_table "announcements", force: :cascade do |t|
    t.text "message", null: false
    t.bigint "author_id", null: false
    t.bigint "user_ids", default: [], null: false, array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_id"], name: "index_announcements_on_author_id"
  end

  create_table "blockouts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "start_at", null: false
    t.datetime "end_at", null: false
    t.datetime "last_occurrence"
    t.text "rrule"
    t.datetime "exdate", default: [], array: true
    t.bigint "parent_id"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_blockouts_on_parent_id"
    t.index ["user_id"], name: "index_blockouts_on_user_id"
  end

  create_table "children", force: :cascade do |t|
    t.bigint "need_id", null: false
    t.integer "age", null: false
    t.integer "sex", null: false
    t.text "notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["need_id"], name: "index_children_on_need_id"
  end

  create_table "languages", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "needs", force: :cascade do |t|
    t.bigint "office_id", null: false
    t.bigint "user_id", null: false
    t.bigint "preferred_language_id", null: false
    t.datetime "start_at", null: false
    t.integer "expected_duration", null: false
    t.integer "number_of_children"
    t.bigint "notified_user_ids", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "race_id"
    t.text "notes"
    t.bigint "unavailable_user_ids", default: [], array: true
    t.index ["office_id"], name: "index_needs_on_office_id"
    t.index ["preferred_language_id"], name: "index_needs_on_preferred_language_id"
    t.index ["race_id"], name: "index_needs_on_race_id"
    t.index ["user_id"], name: "index_needs_on_user_id"
  end

  create_table "needs_social_workers", force: :cascade do |t|
    t.bigint "need_id", null: false
    t.bigint "social_worker_id", null: false
    t.index ["need_id"], name: "index_needs_social_workers_on_need_id"
    t.index ["social_worker_id"], name: "index_needs_social_workers_on_social_worker_id"
  end

  create_table "office_users", force: :cascade do |t|
    t.bigint "office_id", null: false
    t.bigint "user_id", null: false
    t.boolean "send_notifications", default: false, null: false
  end

  create_table "offices", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "region", default: 0, null: false
  end

  create_table "races", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shifts", force: :cascade do |t|
    t.bigint "need_id", null: false
    t.bigint "user_id"
    t.datetime "start_at", null: false
    t.integer "duration", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["need_id"], name: "index_shifts_on_need_id"
    t.index ["user_id"], name: "index_shifts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.integer "sign_in_count"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.integer "current_sign_in_ip"
    t.integer "last_sign_in_ip"
    t.string "role", null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.string "first_name"
    t.string "last_name"
    t.date "birth_date"
    t.string "phone"
    t.date "resident_since"
    t.text "discovered_omd_by"
    t.boolean "medical_limitations"
    t.text "medical_limitations_desc"
    t.boolean "conviction"
    t.text "conviction_desc"
    t.string "time_zone"
    t.bigint "race_id"
    t.bigint "first_language_id"
    t.bigint "second_language_id"
    t.boolean "verified", default: false, null: false
    t.boolean "deactivated", default: false, null: false
    t.boolean "receive_sms_notifications", default: true, null: false
    t.boolean "receive_email_notifications", default: false, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "announcements", "users", column: "author_id"
  add_foreign_key "blockouts", "blockouts", column: "parent_id"
  add_foreign_key "blockouts", "users"
  add_foreign_key "needs", "languages", column: "preferred_language_id"
  add_foreign_key "needs", "offices"
  add_foreign_key "needs", "users"
  add_foreign_key "shifts", "needs"
  add_foreign_key "shifts", "users"
end
