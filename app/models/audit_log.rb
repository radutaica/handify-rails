class AuditLog < ApplicationRecord
  # Associations
  belongs_to :user, optional: true
  belongs_to :admin, class_name: 'User', optional: true

  # Enums
  enum :action_type, {
    login: 'login',
    logout: 'logout',
    data_access: 'data_access',
    data_modification: 'data_modification',
    data_deletion: 'data_deletion',
    data_export: 'data_export',
    consent_given: 'consent_given',
    consent_withdrawn: 'consent_withdrawn',
    profile_view: 'profile_view',
    sensitive_data_access: 'sensitive_data_access'
  }

  # Validations
  validates :action_type, presence: true

  # Scopes
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :by_admin, ->(admin_id) { where(admin_id: admin_id) }
  scope :by_action, ->(action) { where(action_type: action) }
  scope :recent, -> { order(created_at: :desc) }
  scope :sensitive, -> { where(action_type: ['sensitive_data_access', 'data_deletion', 'data_export']) }

  # Class methods for logging specific actions
  def self.log_login(user, ip_address, user_agent)
    create!(
      user: user,
      action_type: 'login',
      ip_address: ip_address,
      user_agent: user_agent
    )
  end

  def self.log_data_access(user, admin, table_name, record_id, reason = nil)
    create!(
      user: user,
      admin: admin,
      action_type: 'data_access',
      table_name: table_name,
      record_id: record_id,
      reason: reason
    )
  end

  def self.log_data_modification(user, table_name, record_id, changes)
    create!(
      user: user,
      action_type: 'data_modification',
      table_name: table_name,
      record_id: record_id,
      changes: changes
    )
  end
end
