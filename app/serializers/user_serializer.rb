# frozen_string_literal: true

class UserSerializer
  def initialize(user)
    @user = user
  end

  def serializable_hash
    {
      id: @user.id,
      email: @user.email,
      first_name: @user.first_name,
      last_name: @user.last_name,
      phone: @user.phone,
      user_type: @user.user_type,
      profile_image_url: @user.profile_image_url,
      preferred_language: @user.preferred_language,
      email_notifications: @user.email_notifications,
      sms_notifications: @user.sms_notifications,
      push_notifications: @user.push_notifications,
      payment_method: @user.payment_method,
      service_categories: @user.service_categories,
      preferred_time_windows: @user.preferred_time_windows,
      default_address: default_address_hash,
      created_at: @user.created_at,
      updated_at: @user.updated_at
    }
  end

  private

  def default_address_hash
    address = @user.addresses.find_by(is_default: true)
    return nil unless address

    {
      id: address.id,
      street_address: address.street_address,
      city: address.city,
      postal_code: address.postal_code,
      country: address.country
    }
  end
end

