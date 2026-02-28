class DataProcessingAgreement < ApplicationRecord
  # Enums
  enum :processor_type, {
    payment: 'payment',
    storage: 'storage',
    analytics: 'analytics',
    email: 'email',
    sms: 'sms',
    other: 'other'
  }

  # Validations
  validates :processor_name, :processor_type, presence: true

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :by_type, ->(type) { where(processor_type: type) }
  scope :expiring_soon, -> { where('expires_at BETWEEN ? AND ?', Time.current, 30.days.from_now) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }

  # Methods
  def deactivate!
    update!(is_active: false)
  end

  def renew!(new_expiration_date)
    update!(
      signed_at: Time.current,
      expires_at: new_expiration_date,
      is_active: true
    )
  end

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def expiring_soon?
    expires_at.present? && expires_at.between?(Time.current, 30.days.from_now)
  end
end
