class CreateGdprCompliance < ActiveRecord::Migration[8.0]
  def change
    # Create gdpr_consents table
    create_table :gdpr_consents, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :consent_type, null: false
      t.string :version, limit: 20, null: false
      t.boolean :consented, null: false
      t.datetime :consented_at
      t.string :ip_address, limit: 45
      t.text :user_agent
      t.datetime :withdrawn_at

      t.timestamps
    end

    add_index :gdpr_consents, [:user_id, :consent_type, :version], name: 'index_gdpr_consents_on_user_consent_version'

    # Create data_deletion_requests table
    create_table :data_deletion_requests, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :request_type, null: false
      t.string :status, default: 'pending'
      t.datetime :requested_at, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :completed_at
      t.string :export_file_url, limit: 500
      t.text :rejection_reason
      t.text :notes
      t.references :processed_by, type: :uuid, foreign_key: { to_table: :users }

      t.timestamps
    end

    # Create audit_logs table
    create_table :audit_logs, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: true
      t.references :admin, type: :uuid, foreign_key: { to_table: :users }
      t.string :action_type, null: false
      t.string :table_name, limit: 100
      t.uuid :record_id
      t.string :ip_address, limit: 45
      t.text :user_agent
      t.jsonb :changes
      t.text :reason

      t.timestamps
    end

    # Create data_breach_log table
    create_table :data_breach_logs, id: :uuid do |t|
      t.string :breach_type, null: false
      t.string :severity, null: false
      t.integer :affected_users_count
      t.jsonb :affected_data_types
      t.text :description, null: false
      t.datetime :discovered_at, null: false
      t.datetime :reported_to_authority_at
      t.datetime :users_notified_at
      t.text :mitigation_actions
      t.string :status, default: 'discovered'
      t.datetime :resolved_at

      t.timestamps
    end

    # Create encryption_keys table
    create_table :encryption_keys, id: :uuid do |t|
      t.string :key_name, limit: 100, null: false
      t.integer :key_version, null: false, default: 1
      t.string :algorithm, limit: 50, null: false
      t.boolean :is_active, default: true
      t.datetime :rotated_at
      t.datetime :expires_at

      t.timestamps
    end

    add_index :encryption_keys, :key_name, unique: true

    # Create data_processing_agreements table
    create_table :data_processing_agreements, id: :uuid do |t|
      t.string :processor_name, limit: 200, null: false
      t.string :processor_type, null: false
      t.string :dpa_url, limit: 500
      t.string :privacy_policy_url, limit: 500
      t.jsonb :data_transferred
      t.boolean :is_active, default: true
      t.datetime :signed_at
      t.datetime :expires_at

      t.timestamps
    end
  end
end
