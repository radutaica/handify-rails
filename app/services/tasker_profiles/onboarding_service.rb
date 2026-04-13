module TaskerProfiles
  class OnboardingService
    attr_reader :user, :params, :errors

    def initialize(user, params)
      @user = user
      @params = params
      @errors = []
    end

    def call
      return failure("Tasker profile already exists") if user.tasker_profile.present?

      ActiveRecord::Base.transaction do
        create_tasker_profile
        create_or_associate_address if address_params.present?
        associate_categories if category_ids.present?
      end

      success
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    rescue StandardError => e
      failure(e.message)
    end

    def success?
      @success
    end

    def tasker_profile
      @tasker_profile
    end

    private

    def create_tasker_profile
      @tasker_profile = user.build_tasker_profile(tasker_profile_params)
      @tasker_profile.save!
    end

    def create_or_associate_address
      user.addresses.create!(address_params)
    end

    def associate_categories
      categories = Category.where(id: category_ids)
      @tasker_profile.categories << categories
    end

    def tasker_profile_params
      params.permit(
        :bio, :hourly_rate, :allows_instant_booking, :instant_booking_buffer_hours,
        :experience_years, :is_active,
        availability: {}, skills: []
      )
    end

    def address_params
      return {} unless params[:address].present?

      params[:address].permit(
        :street_address, :city, :county, :postal_code, :country,
        :latitude, :longitude, :is_default
      )
    end

    def category_ids
      params[:category_ids] || []
    end

    def success
      @success = true
      self
    end

    def failure(error_messages)
      @success = false
      @errors = Array(error_messages)
      self
    end
  end
end
