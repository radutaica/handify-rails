class GdprConsent < ApplicationRecord
  # Associations
  belongs_to :user

  # Enums
  enum :consent_type, {
    terms_of_service: 'terms_of_service',
    privacy_policy: 'privacy_policy',
    marketing_emails: 'marketing_emails',
    data_processing: 'data_processing',
    cookies: 'cookies',
    analytics: 'analytics',
    third_party_sharing: 'third_party_sharing'
  }

  # Validations
  validates :user_id, :consent_type, :version, :consented, presence: true

  # Scopes
  scope :consented, -> { where(consented: true, withdrawn_at: nil) }
  scope :withdrawn, -> { where.not(withdrawn_at: nil) }
  scope :by_type, ->(type) { where(consent_type: type) }
  scope :by_version, ->(version) { where(version: version) }
  scope :active, -> { consented.where(withdrawn_at: nil) }

  # Methods
  def withdraw!
    update!(withdrawn_at: Time.current)
  end

  def active?
    consented && withdrawn_at.nil?
  end

  def self.record_consent(user, consent_type, version, ip_address, user_agent)
    create!(
      user: user,
      consent_type: consent_type,
      version: version,
      consented: true,
      consented_at: Time.current,
      ip_address: ip_address,
      user_agent: user_agent
    )
  end
end
