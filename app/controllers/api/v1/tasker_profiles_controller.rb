module Api
  module V1
    class TaskerProfilesController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show]

      private

      def resource_params
        params.require(:tasker_profile).permit(
          :bio, :hourly_rate, :allows_instant_booking, :instant_booking_buffer_hours,
          :experience_years, :is_active,
          availability: {}, skills: []
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
