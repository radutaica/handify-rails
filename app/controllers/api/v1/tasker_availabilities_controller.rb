module Api
  module V1
    class TaskerAvailabilitiesController < BaseController
      def index
        availabilities = TaskerAvailability.for_tasker(params[:tasker_id] || current_user.id)
        availabilities = availabilities.upcoming if params[:upcoming] == 'true'
        availabilities = availabilities.available if params[:available_only] == 'true'

        render json: availabilities, status: :ok
      end

      private

      def resource_params
        params.require(:tasker_availability).permit(
          :date, :start_time, :end_time, :is_available
        )
      end

      def apply_filters(resources)
        resources = resources.where(tasker_id: params[:tasker_id]) if params[:tasker_id].present?
        resources = resources.where(date: params[:date]) if params[:date].present?
        resources
      end
    end
  end
end
