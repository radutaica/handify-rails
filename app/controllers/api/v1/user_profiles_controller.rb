# frozen_string_literal: true

module Api
  module V1
    class UserProfilesController < BaseController
      # POST /api/v1/user_profiles/complete
      def complete
        ActiveRecord::Base.transaction do
          # Update user profile fields
          update_user_profile
          
          # Update or create default address
          update_user_address
          
          if current_user.save
            render json: {
              status: { code: 200, message: 'Profile completed successfully.' },
              data: UserSerializer.new(current_user).serializable_hash
            }, status: :ok
          else
            render json: {
              status: { message: "Profile couldn't be completed. #{current_user.errors.full_messages.to_sentence}" }
            }, status: :unprocessable_entity
          end
        end
      rescue StandardError => e
        render json: {
          status: { message: "An error occurred: #{e.message}" }
        }, status: :unprocessable_entity
      end

      private

      def update_user_profile
        profile_params = complete_profile_params
        
        # Update photo_url (mapped to profile_image_url)
        current_user.profile_image_url = profile_params[:photo_url] if profile_params[:photo_url].present?
        
        # Update user_type (map 'provider' to 'tasker', default to 'customer' if not provided)
        user_type = profile_params[:user_type] || 'customer'
        user_type = 'tasker' if user_type == 'provider'
        current_user.user_type = user_type
        
        # Update preferences
        current_user.preferred_language = profile_params[:preferred_language] || 'English'
        current_user.email_notifications = profile_params[:email_notifications] || false
        current_user.sms_notifications = profile_params[:sms_notifications] || false
        current_user.push_notifications = profile_params[:push_notifications] != false # default true
        current_user.payment_method = profile_params[:payment_method] || 'credit_card'
        
        # Update arrays (ensure they're arrays)
        current_user.service_categories = Array(profile_params[:service_categories] || [])
        current_user.preferred_time_windows = Array(profile_params[:preferred_time_windows] || [])
      end

      def update_user_address
        location_params = complete_profile_params
        
        # Only update address if at least one location field is provided (not empty string)
        has_location_data = location_params[:location_address].present? || 
                           location_params[:location_city].present? || 
                           location_params[:location_zip].present?
        
        return unless has_location_data
        
        # Find or create default address
        default_address = current_user.addresses.find_or_initialize_by(is_default: true)
        
        # Update address fields (use defaults if not provided, but ensure required fields are set)
        default_address.street_address = location_params[:location_address].presence || default_address.street_address || ''
        default_address.city = location_params[:location_city].presence || default_address.city || 'New York'
        default_address.postal_code = location_params[:location_zip].presence || default_address.postal_code || '10001'
        default_address.is_default = true
        
        # Ensure only one default address
        if default_address.new_record? || default_address.changed?
          # Unset other default addresses before saving
          if default_address.persisted?
            current_user.addresses.where.not(id: default_address.id).update_all(is_default: false)
          else
            current_user.addresses.update_all(is_default: false)
          end
          default_address.save!
        end
      end

      def complete_profile_params
        params.require(:profileData).permit(
          :photo_url,
          :preferred_language,
          :email_notifications,
          :sms_notifications,
          :push_notifications,
          :user_type,
          :location_address,
          :location_city,
          :location_zip,
          :payment_method,
          service_categories: [],
          preferred_time_windows: []
        )
      end
    end
  end
end

