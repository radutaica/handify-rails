class DataBreachLog < ApplicationRecord
  # Enums
  enum :breach_type, {
    unauthorized_access: 'unauthorized_access',
    data_leak: 'data_leak',
    system_compromise: 'system_compromise',
    malware: 'malware',
    human_error: 'human_error'
  }

  enum :severity, {
    low: 'low',
    medium: 'medium',
    high: 'high',
    critical: 'critical'
  }

  enum :status, {
    discovered: 'discovered',
    investigating: 'investigating',
    contained: 'contained',
    resolved: 'resolved'
  }

  # Validations
  validates :breach_type, :severity, :description, :discovered_at, presence: true

  # Scopes
  scope :by_severity, ->(severity) { where(severity: severity) }
  scope :unresolved, -> { where.not(status: 'resolved') }
  scope :critical, -> { where(severity: 'critical') }
  scope :recent, -> { order(discovered_at: :desc) }

  # Methods
  def report_to_authority!
    update!(reported_to_authority_at: Time.current)
  end

  def notify_users!
    update!(users_notified_at: Time.current)
  end

  def resolve!(mitigation_text)
    update!(
      status: 'resolved',
      mitigation_actions: mitigation_text,
      resolved_at: Time.current
    )
  end

  def requires_authority_notification?
    critical? || high? || affected_users_count.to_i > 100
  end

  def requires_user_notification?
    affected_users_count.to_i > 0
  end
end
