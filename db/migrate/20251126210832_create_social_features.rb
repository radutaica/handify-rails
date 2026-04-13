class CreateSocialFeatures < ActiveRecord::Migration[8.0]
  def change
    # Create reviews table
    create_table :reviews, id: :uuid do |t|
      t.references :task, type: :uuid, null: false, foreign_key: true
      t.references :reviewer, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.references :reviewee, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.integer :rating, null: false
      t.text :comment
      t.string :review_type, null: false
      t.jsonb :tags
      t.boolean :is_public, default: true

      t.timestamps
    end

    add_index :reviews, [:task_id, :reviewer_id], unique: true

    # Create messages table
    create_table :messages, id: :uuid do |t|
      t.references :task, type: :uuid, foreign_key: true
      t.references :direct_request, type: :uuid, foreign_key: true
      t.references :sender, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.references :receiver, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.text :message, null: false
      t.boolean :is_read, default: false
      t.datetime :read_at
      t.string :attachment_url, limit: 500

      t.timestamps
    end

    # Create notifications table
    create_table :notifications, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :type, null: false
      t.string :title, limit: 200, null: false
      t.text :message, null: false
      t.uuid :related_id
      t.boolean :is_read, default: false
      t.datetime :read_at

      t.timestamps
    end

    # Create favorites table
    create_table :favorites, id: :uuid do |t|
      t.references :customer, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.references :tasker, type: :uuid, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :favorites, [:customer_id, :tasker_id], unique: true

    # Create portfolio_items table
    create_table :portfolio_items, id: :uuid do |t|
      t.references :tasker, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.string :title, limit: 200, null: false
      t.text :description
      t.references :category, type: :uuid, foreign_key: true
      t.jsonb :images, null: false
      t.references :task, type: :uuid, foreign_key: true
      t.boolean :is_featured, default: false

      t.timestamps
    end

    # Create disputes table
    create_table :disputes, id: :uuid do |t|
      t.references :task, type: :uuid, null: false, foreign_key: true
      t.references :raised_by, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.text :reason, null: false
      t.string :status, default: 'open'
      t.text :resolution
      t.references :resolved_by, type: :uuid, foreign_key: { to_table: :users }
      t.datetime :resolved_at

      t.timestamps
    end
  end
end
