# frozen_string_literal: true

module Geocodable
  extend ActiveSupport::Concern

  included do
    geocoded_by :full_address
    after_validation :geocode, if: ->(obj) { obj.address_fields_changed? && obj.latitude.blank? }
  end

  def address_fields_changed?
    street_address_changed? || city_changed? || county_changed? || postal_code_changed?
  end
end
