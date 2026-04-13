class CreateTasksAndBidding < ActiveRecord::Migration[8.0]
  def change
    # Create tasks table
    create_table :tasks, id: :uuid do |t|
      t.references :customer, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.references :category, type: :uuid, null: false, foreign_key: true
      t.string :title, limit: 200, null: false
      t.text :description, null: false
      t.references :address, type: :uuid, null: false, foreign_key: true
      t.date :task_date
      t.time :task_time
      t.boolean :is_flexible_timing, default: false
      t.decimal :estimated_hours, precision: 4, scale: 2

      # Pricing model flexibility
      t.string :pricing_type, null: false, default: 'bidding'
      t.decimal :budget_min, precision: 10, scale: 2
      t.decimal :budget_max, precision: 10, scale: 2
      t.decimal :fixed_price, precision: 10, scale: 2
      t.decimal :hourly_budget, precision: 10, scale: 2

      # Booking type
      t.string :booking_type, null: false, default: 'open_bidding'

      t.string :status, default: 'open'
      t.string :urgency, default: 'medium'
      t.jsonb :images
      t.text :requirements
      t.references :assigned_tasker, type: :uuid, foreign_key: { to_table: :users }
      t.datetime :assigned_at
      t.datetime :completed_at
      t.datetime :cancelled_at
      t.text :cancellation_reason

      t.timestamps
    end

    # Create bids table
    create_table :bids, id: :uuid do |t|
      t.references :task, type: :uuid, null: false, foreign_key: true
      t.references :tasker, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.decimal :estimated_hours, precision: 4, scale: 2
      t.date :proposed_date
      t.time :proposed_time
      t.text :message
      t.string :status, default: 'pending'

      t.timestamps
    end

    add_index :bids, [:task_id, :tasker_id], unique: true

    # Create direct_requests table
    create_table :direct_requests, id: :uuid do |t|
      t.references :customer, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.references :tasker, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.references :category, type: :uuid, null: false, foreign_key: true
      t.string :title, limit: 200, null: false
      t.text :description, null: false
      t.references :address, type: :uuid, null: false, foreign_key: true
      t.date :preferred_date
      t.time :preferred_time
      t.decimal :estimated_hours, precision: 4, scale: 2
      t.decimal :proposed_amount, precision: 10, scale: 2
      t.string :status, default: 'pending'
      t.decimal :tasker_counter_amount, precision: 10, scale: 2
      t.text :tasker_message
      t.references :task, type: :uuid, foreign_key: true
      t.datetime :expires_at

      t.timestamps
    end

    # Create tasker_availability table
    create_table :tasker_availability, id: :uuid do |t|
      t.references :tasker, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.date :date, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.boolean :is_available, default: true
      t.boolean :is_booked, default: false
      t.references :task, type: :uuid, foreign_key: true

      t.timestamps
    end

    add_index :tasker_availability, [:tasker_id, :date, :start_time], unique: true, name: 'index_tasker_availability_unique'
  end
end
