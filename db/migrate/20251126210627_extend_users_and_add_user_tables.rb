class ExtendUsersAndAddUserTables < ActiveRecord::Migration[8.0]
  def change
    # Extend users table with additional fields
    change_table :users do |t|
      # Remove default empty string from email (Devise default)
      t.change :email, :string, null: false, default: nil

      # Additional user fields
      t.string :phone, limit: 20
      t.string :first_name, limit: 100, null: false
      t.string :last_name, limit: 100, null: false
      t.string :user_type, null: false, default: 'customer'
      t.string :profile_image_url, limit: 500
      t.date :date_of_birth
      t.boolean :id_verified, default: false
      t.boolean :email_verified, default: false
      t.boolean :phone_verified, default: false
      t.string :status, default: 'active'

      # GDPR Data Management
      t.date :data_retention_until
      t.boolean :anonymized, default: false
      t.datetime :anonymized_at
      t.datetime :last_active_at, default: -> { 'CURRENT_TIMESTAMP' }
    end

    add_index :users, :phone, unique: true
    add_index :users, :status
    add_index :users, :data_retention_until
    add_index :users, :last_active_at

    # Create tasker_profiles table
    create_table :tasker_profiles, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true, index: { unique: true }
      t.text :bio
      t.decimal :hourly_rate, precision: 10, scale: 2
      t.boolean :allows_instant_booking, default: false
      t.integer :instant_booking_buffer_hours, default: 24
      t.jsonb :availability
      t.jsonb :skills
      t.integer :experience_years
      t.string :background_check_status, default: 'pending'
      t.datetime :background_check_date
      t.boolean :insurance_verified, default: false
      t.decimal :avg_rating, precision: 3, scale: 2, default: 0
      t.integer :total_tasks_completed, default: 0
      t.decimal :total_earnings, precision: 12, scale: 2, default: 0
      t.decimal :response_rate, precision: 5, scale: 2, default: 0
      t.decimal :response_time_hours, precision: 6, scale: 2
      t.string :stripe_account_id
      t.boolean :is_active, default: true

      t.timestamps
    end

    # Create addresses table
    create_table :addresses, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :label, limit: 50
      t.string :street_address, null: false
      t.string :city, limit: 100, null: false
      t.string :county, limit: 100
      t.string :postal_code, limit: 20
      t.string :country, limit: 2, default: 'RO'
      t.decimal :latitude, precision: 10, scale: 8
      t.decimal :longitude, precision: 11, scale: 8
      t.boolean :is_default, default: false

      t.timestamps
    end

    # Create admin_users table
    create_table :admin_users, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true, index: { unique: true }
      t.string :role, null: false
      t.jsonb :permissions
      t.boolean :is_active, default: true

      t.timestamps
    end
  end
end
