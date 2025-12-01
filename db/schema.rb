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

ActiveRecord::Schema[8.0].define(version: 2025_11_27_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "label", limit: 50
    t.string "street_address", null: false
    t.string "city", limit: 100, null: false
    t.string "county", limit: 100
    t.string "postal_code", limit: 20
    t.string "country", limit: 2, default: "RO"
    t.decimal "latitude", precision: 10, scale: 8
    t.decimal "longitude", precision: 11, scale: 8
    t.boolean "is_default", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "admin_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "role", null: false
    t.jsonb "permissions"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_admin_users_on_user_id", unique: true
  end

  create_table "audit_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.uuid "admin_id"
    t.string "action_type", null: false
    t.string "table_name", limit: 100
    t.uuid "record_id"
    t.string "ip_address", limit: 45
    t.text "user_agent"
    t.jsonb "changes"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_audit_logs_on_admin_id"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "bids", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "task_id", null: false
    t.uuid "tasker_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.decimal "estimated_hours", precision: 4, scale: 2
    t.date "proposed_date"
    t.time "proposed_time"
    t.text "message"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id", "tasker_id"], name: "index_bids_on_task_id_and_tasker_id", unique: true
    t.index ["task_id"], name: "index_bids_on_task_id"
    t.index ["tasker_id"], name: "index_bids_on_tasker_id"
  end

  create_table "categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "slug", limit: 100, null: false
    t.text "description"
    t.string "icon_url", limit: 500
    t.uuid "parent_id"
    t.decimal "suggested_hourly_rate", precision: 10, scale: 2
    t.boolean "is_active", default: true
    t.integer "sort_order", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "data_breach_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "breach_type", null: false
    t.string "severity", null: false
    t.integer "affected_users_count"
    t.jsonb "affected_data_types"
    t.text "description", null: false
    t.datetime "discovered_at", null: false
    t.datetime "reported_to_authority_at"
    t.datetime "users_notified_at"
    t.text "mitigation_actions"
    t.string "status", default: "discovered"
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "data_deletion_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "request_type", null: false
    t.string "status", default: "pending"
    t.datetime "requested_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "completed_at"
    t.string "export_file_url", limit: 500
    t.text "rejection_reason"
    t.text "notes"
    t.uuid "processed_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["processed_by_id"], name: "index_data_deletion_requests_on_processed_by_id"
    t.index ["user_id"], name: "index_data_deletion_requests_on_user_id"
  end

  create_table "data_processing_agreements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "processor_name", limit: 200, null: false
    t.string "processor_type", null: false
    t.string "dpa_url", limit: 500
    t.string "privacy_policy_url", limit: 500
    t.jsonb "data_transferred"
    t.boolean "is_active", default: true
    t.datetime "signed_at"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "direct_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "customer_id", null: false
    t.uuid "tasker_id", null: false
    t.uuid "category_id", null: false
    t.string "title", limit: 200, null: false
    t.text "description", null: false
    t.uuid "address_id", null: false
    t.date "preferred_date"
    t.time "preferred_time"
    t.decimal "estimated_hours", precision: 4, scale: 2
    t.decimal "proposed_amount", precision: 10, scale: 2
    t.string "status", default: "pending"
    t.decimal "tasker_counter_amount", precision: 10, scale: 2
    t.text "tasker_message"
    t.uuid "task_id"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_direct_requests_on_address_id"
    t.index ["category_id"], name: "index_direct_requests_on_category_id"
    t.index ["customer_id"], name: "index_direct_requests_on_customer_id"
    t.index ["task_id"], name: "index_direct_requests_on_task_id"
    t.index ["tasker_id"], name: "index_direct_requests_on_tasker_id"
  end

  create_table "disputes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "task_id", null: false
    t.uuid "raised_by_id", null: false
    t.text "reason", null: false
    t.string "status", default: "open"
    t.text "resolution"
    t.uuid "resolved_by_id"
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["raised_by_id"], name: "index_disputes_on_raised_by_id"
    t.index ["resolved_by_id"], name: "index_disputes_on_resolved_by_id"
    t.index ["task_id"], name: "index_disputes_on_task_id"
  end

  create_table "encryption_keys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key_name", limit: 100, null: false
    t.integer "key_version", default: 1, null: false
    t.string "algorithm", limit: 50, null: false
    t.boolean "is_active", default: true
    t.datetime "rotated_at"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key_name"], name: "index_encryption_keys_on_key_name", unique: true
  end

  create_table "favorites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "customer_id", null: false
    t.uuid "tasker_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id", "tasker_id"], name: "index_favorites_on_customer_id_and_tasker_id", unique: true
    t.index ["customer_id"], name: "index_favorites_on_customer_id"
    t.index ["tasker_id"], name: "index_favorites_on_tasker_id"
  end

  create_table "gdpr_consents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "consent_type", null: false
    t.string "version", limit: 20, null: false
    t.boolean "consented", null: false
    t.datetime "consented_at"
    t.string "ip_address", limit: 45
    t.text "user_agent"
    t.datetime "withdrawn_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "consent_type", "version"], name: "index_gdpr_consents_on_user_consent_version"
    t.index ["user_id"], name: "index_gdpr_consents_on_user_id"
  end

  create_table "jwt_denylist", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.index ["jti"], name: "index_jwt_denylist_on_jti"
  end

  create_table "messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "task_id"
    t.uuid "direct_request_id"
    t.uuid "sender_id", null: false
    t.uuid "receiver_id", null: false
    t.text "message", null: false
    t.boolean "is_read", default: false
    t.datetime "read_at"
    t.string "attachment_url", limit: 500
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["direct_request_id"], name: "index_messages_on_direct_request_id"
    t.index ["receiver_id"], name: "index_messages_on_receiver_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
    t.index ["task_id"], name: "index_messages_on_task_id"
  end

  create_table "notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "type", null: false
    t.string "title", limit: 200, null: false
    t.text "message", null: false
    t.uuid "related_id"
    t.boolean "is_read", default: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "portfolio_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "tasker_id", null: false
    t.string "title", limit: 200, null: false
    t.text "description"
    t.uuid "category_id"
    t.jsonb "images", null: false
    t.uuid "task_id"
    t.boolean "is_featured", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_portfolio_items_on_category_id"
    t.index ["task_id"], name: "index_portfolio_items_on_task_id"
    t.index ["tasker_id"], name: "index_portfolio_items_on_tasker_id"
  end

  create_table "reviews", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "task_id", null: false
    t.uuid "reviewer_id", null: false
    t.uuid "reviewee_id", null: false
    t.integer "rating", null: false
    t.text "comment"
    t.string "review_type", null: false
    t.jsonb "tags"
    t.boolean "is_public", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reviewee_id"], name: "index_reviews_on_reviewee_id"
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
    t.index ["task_id", "reviewer_id"], name: "index_reviews_on_task_id_and_reviewer_id", unique: true
    t.index ["task_id"], name: "index_reviews_on_task_id"
  end

  create_table "tasker_availability", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "tasker_id", null: false
    t.date "date", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.boolean "is_available", default: true
    t.boolean "is_booked", default: false
    t.uuid "task_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_tasker_availability_on_task_id"
    t.index ["tasker_id", "date", "start_time"], name: "index_tasker_availability_unique", unique: true
    t.index ["tasker_id"], name: "index_tasker_availability_on_tasker_id"
  end

  create_table "tasker_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.text "bio"
    t.decimal "hourly_rate", precision: 10, scale: 2
    t.boolean "allows_instant_booking", default: false
    t.integer "instant_booking_buffer_hours", default: 24
    t.jsonb "availability"
    t.jsonb "skills"
    t.integer "experience_years"
    t.string "background_check_status", default: "pending"
    t.datetime "background_check_date"
    t.boolean "insurance_verified", default: false
    t.decimal "avg_rating", precision: 3, scale: 2, default: "0.0"
    t.integer "total_tasks_completed", default: 0
    t.decimal "total_earnings", precision: 12, scale: 2, default: "0.0"
    t.decimal "response_rate", precision: 5, scale: 2, default: "0.0"
    t.decimal "response_time_hours", precision: 6, scale: 2
    t.string "stripe_account_id"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_tasker_profiles_on_user_id", unique: true
  end

  create_table "tasks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "customer_id", null: false
    t.uuid "category_id", null: false
    t.string "title", limit: 200, null: false
    t.text "description", null: false
    t.uuid "address_id", null: false
    t.date "task_date"
    t.time "task_time"
    t.boolean "is_flexible_timing", default: false
    t.decimal "estimated_hours", precision: 4, scale: 2
    t.string "pricing_type", default: "bidding", null: false
    t.decimal "budget_min", precision: 10, scale: 2
    t.decimal "budget_max", precision: 10, scale: 2
    t.decimal "fixed_price", precision: 10, scale: 2
    t.decimal "hourly_budget", precision: 10, scale: 2
    t.string "booking_type", default: "open_bidding", null: false
    t.string "status", default: "open"
    t.string "urgency", default: "medium"
    t.jsonb "images"
    t.text "requirements"
    t.uuid "assigned_tasker_id"
    t.datetime "assigned_at"
    t.datetime "completed_at"
    t.datetime "cancelled_at"
    t.text "cancellation_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_tasks_on_address_id"
    t.index ["assigned_tasker_id"], name: "index_tasks_on_assigned_tasker_id"
    t.index ["category_id"], name: "index_tasks_on_category_id"
    t.index ["customer_id"], name: "index_tasks_on_customer_id"
  end

  create_table "transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "task_id", null: false
    t.uuid "customer_id", null: false
    t.uuid "tasker_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.decimal "platform_fee", precision: 10, scale: 2, null: false
    t.decimal "platform_fee_percentage", precision: 5, scale: 2, null: false
    t.decimal "tasker_amount", precision: 10, scale: 2, null: false
    t.string "stripe_payment_intent_id"
    t.string "stripe_transfer_id"
    t.string "status", default: "pending"
    t.string "payment_method", default: "card"
    t.datetime "paid_at"
    t.datetime "released_at"
    t.datetime "refunded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_transactions_on_customer_id"
    t.index ["task_id"], name: "index_transactions_on_task_id"
    t.index ["tasker_id"], name: "index_transactions_on_tasker_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone", limit: 20
    t.string "first_name", limit: 100, null: false
    t.string "last_name", limit: 100, null: false
    t.string "user_type", default: "customer", null: false
    t.string "profile_image_url", limit: 500
    t.date "date_of_birth"
    t.boolean "id_verified", default: false
    t.boolean "email_verified", default: false
    t.boolean "phone_verified", default: false
    t.string "status", default: "active"
    t.date "data_retention_until"
    t.boolean "anonymized", default: false
    t.datetime "anonymized_at"
    t.datetime "last_active_at", default: -> { "CURRENT_TIMESTAMP" }
    t.string "preferred_language", default: "English"
    t.boolean "email_notifications", default: false
    t.boolean "sms_notifications", default: false
    t.boolean "push_notifications", default: true
    t.string "payment_method", default: "credit_card"
    t.jsonb "service_categories", default: []
    t.jsonb "preferred_time_windows", default: []
    t.index ["data_retention_until"], name: "index_users_on_data_retention_until"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["last_active_at"], name: "index_users_on_last_active_at"
    t.index ["phone"], name: "index_users_on_phone", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["status"], name: "index_users_on_status"
  end

  add_foreign_key "addresses", "users"
  add_foreign_key "admin_users", "users"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "audit_logs", "users", column: "admin_id"
  add_foreign_key "bids", "tasks"
  add_foreign_key "bids", "users", column: "tasker_id"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "data_deletion_requests", "users"
  add_foreign_key "data_deletion_requests", "users", column: "processed_by_id"
  add_foreign_key "direct_requests", "addresses"
  add_foreign_key "direct_requests", "categories"
  add_foreign_key "direct_requests", "tasks"
  add_foreign_key "direct_requests", "users", column: "customer_id"
  add_foreign_key "direct_requests", "users", column: "tasker_id"
  add_foreign_key "disputes", "tasks"
  add_foreign_key "disputes", "users", column: "raised_by_id"
  add_foreign_key "disputes", "users", column: "resolved_by_id"
  add_foreign_key "favorites", "users", column: "customer_id"
  add_foreign_key "favorites", "users", column: "tasker_id"
  add_foreign_key "gdpr_consents", "users"
  add_foreign_key "messages", "direct_requests"
  add_foreign_key "messages", "tasks"
  add_foreign_key "messages", "users", column: "receiver_id"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "portfolio_items", "categories"
  add_foreign_key "portfolio_items", "tasks"
  add_foreign_key "portfolio_items", "users", column: "tasker_id"
  add_foreign_key "reviews", "tasks"
  add_foreign_key "reviews", "users", column: "reviewee_id"
  add_foreign_key "reviews", "users", column: "reviewer_id"
  add_foreign_key "tasker_availability", "tasks"
  add_foreign_key "tasker_availability", "users", column: "tasker_id"
  add_foreign_key "tasker_profiles", "users"
  add_foreign_key "tasks", "addresses"
  add_foreign_key "tasks", "categories"
  add_foreign_key "tasks", "users", column: "assigned_tasker_id"
  add_foreign_key "tasks", "users", column: "customer_id"
  add_foreign_key "transactions", "tasks"
  add_foreign_key "transactions", "users", column: "customer_id"
  add_foreign_key "transactions", "users", column: "tasker_id"
end
