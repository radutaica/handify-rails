class Address < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :tasks, dependent: :restrict_with_error
  has_many :direct_requests, dependent: :restrict_with_error

  # Validations
  validates :user_id, presence: true
  validates :street_address, :city, presence: true
  validates :country, presence: true, length: { is: 2 }
  validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_nil: true
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_nil: true

  # Callbacks
  before_save :ensure_single_default, if: :is_default?

  # Scopes
  scope :default_addresses, -> { where(is_default: true) }

  # Methods
  def full_address
    [street_address, city, county, postal_code, country].compact.join(', ')
  end

  private

  def ensure_single_default
    Address.where(user_id: user_id, is_default: true)
           .where.not(id: id)
           .update_all(is_default: false)
  end
end
