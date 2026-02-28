class Address < ApplicationRecord
  include Geocodable

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

  scope :near_coordinates, ->(lat, lng, radius_km = 10) {
    where(
      "( 6371 * acos( LEAST(1.0, cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude)) ) ) ) <= ?",
      lat, lng, lat, radius_km
    ).where.not(latitude: nil, longitude: nil)
  }

  # Methods
  def full_address
    [street_address, city, county, postal_code, country].compact.join(', ')
  end

  def distance_to_coordinates(lat, lng)
    return nil unless latitude.present? && longitude.present?

    rad = Math::PI / 180
    dlat = (lat.to_f - latitude.to_f) * rad
    dlng = (lng.to_f - longitude.to_f) * rad
    a = Math.sin(dlat / 2)**2 + Math.cos(latitude.to_f * rad) * Math.cos(lat.to_f * rad) * Math.sin(dlng / 2)**2
    6371 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  end

  private

  def ensure_single_default
    Address.where(user_id: user_id, is_default: true)
           .where.not(id: id)
           .update_all(is_default: false)
  end
end
