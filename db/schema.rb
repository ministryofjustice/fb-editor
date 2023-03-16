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

ActiveRecord::Schema.define(version: 2023_03_14_164512) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "from_addresses", comment: "DEPRECATED: We have kept the table to ensure backwards compatibility.", force: :cascade do |t|
    t.uuid "service_id", null: false
    t.string "email", null: false
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["service_id"], name: "index_from_addresses_on_service_id"
  end

  create_table "identities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "email"
    t.uuid "user_id"
    t.index ["email"], name: "index_identities_on_email"
    t.index ["provider", "uid"], name: "index_identities_on_provider_and_uid"
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "legacy_service_names", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "publish_services", force: :cascade do |t|
    t.string "deployment_environment", null: false
    t.uuid "service_id", null: false
    t.string "status", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "version_id"
    t.uuid "user_id"
    t.uuid "autocomplete_ids", default: [], array: true
    t.index ["service_id", "deployment_environment"], name: "index_publish_services_on_service_id_and_deployment_environment"
    t.index ["service_id", "status", "deployment_environment"], name: "index_publish_services_on_service_status_deployment"
    t.index ["service_id"], name: "index_publish_services_on_service_id"
    t.index ["user_id"], name: "index_publish_services_on_user_id"
  end

  create_table "service_configurations", force: :cascade do |t|
    t.string "name", null: false
    t.string "value", null: false
    t.string "deployment_environment", null: false
    t.uuid "service_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["service_id", "deployment_environment", "name"], name: "index_service_configurations_on_service_deployment_name"
    t.index ["service_id", "deployment_environment"], name: "index_service_configurations_on_service_id_and_deployment_env"
    t.index ["service_id"], name: "index_service_configurations_on_service_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "submission_settings", force: :cascade do |t|
    t.boolean "send_email", default: false
    t.string "deployment_environment"
    t.uuid "service_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "service_csv_output", default: false
    t.boolean "send_confirmation_email", default: false
    t.boolean "payment_link", default: false
    t.index ["service_id", "deployment_environment"], name: "submission_settings_id_and_environment"
    t.index ["service_id"], name: "index_submission_settings_on_service_id"
  end

  create_table "uptime_checks", force: :cascade do |t|
    t.uuid "service_id", null: false
    t.string "check_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["service_id"], name: "index_uptime_checks_on_service_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.string "timezone", default: "London"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "identities", "users"
end
