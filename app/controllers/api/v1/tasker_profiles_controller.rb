module Api
  module V1
    class TaskerProfilesController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show]

      # POST /api/v1/tasker_profiles/onboarding
      def onboarding
        service = TaskerProfiles::OnboardingService.new(current_user, onboarding_params)
        result = service.call

        if result.success?
          render json: service.tasker_profile, status: :created
        else
          render json: { errors: service.errors }, status: :unprocessable_entity
        end
      end

      private

      def resource_params
        params.require(:tasker_profile).permit(
          :bio, :hourly_rate, :allows_instant_booking, :instant_booking_buffer_hours,
          :experience_years, :is_active,
          availability: {}, skills: []
        )
      end

      def onboarding_params
        params.require(:tasker_profile).permit(
          :bio, :hourly_rate, :allows_instant_booking, :instant_booking_buffer_hours,
          :experience_years, :is_active,
          availability: {}, skills: [], category_ids: [],
          address: [
            :street_address, :city, :county, :postal_code, :country,
            :latitude, :longitude, :is_default
          ]
        )
      end

      def apply_filters(resources)
        resources = resources.active if params[:active_only] == 'true'
        resources = resources.verified if params[:verified_only] == 'true'
        resources = resources.instant_booking_available if params[:instant_booking] == 'true'
        resources = resources.with_high_rating if params[:high_rated] == 'true'
        resources
      end
    end
  end
end
