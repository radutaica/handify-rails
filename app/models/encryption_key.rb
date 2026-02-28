class EncryptionKey < ApplicationRecord
  # Validations
  validates :key_name, :algorithm, presence: true
  validates :key_name, uniqueness: true
  validates :key_version, presence: true, numericality: { only_integer: true, greater_than: 0 }

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }
  scope :expiring_soon, -> { where('expires_at BETWEEN ? AND ?', Time.current, 30.days.from_now) }

  # Methods
  def rotate!(new_version)
    transaction do
      update!(is_active: false, rotated_at: Time.current)
      self.class.create!(
        key_name: key_name,
        key_version: new_version,
        algorithm: algorithm,
        is_active: true,
        expires_at: 1.year.from_now
      )
    end
  end

  def deactivate!
    update!(is_active: false)
  end

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def expiring_soon?
    expires_at.present? && expires_at.between?(Time.current, 30.days.from_now)
  end
end
