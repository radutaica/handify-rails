module Api
  module V1
    class TasksController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show]

      private

      def resource_params
        params.require(:task).permit(
          :category_id, :address_id, :title, :description,
          :task_date, :task_time, :is_flexible_timing, :estimated_hours,
          :pricing_type, :budget_min, :budget_max, :fixed_price, :hourly_budget,
          :booking_type, :urgency, :requirements, :status,
          images: []
        )
      end

      def apply_filters(resources)
        resources = resources.where(category_id: params[:category_id]) if params[:category_id].present?
        resources = resources.where(status: params[:status]) if params[:status].present?
        resources = resources.where(urgency: params[:urgency]) if params[:urgency].present?
        resources = resources.where(booking_type: params[:booking_type]) if params[:booking_type].present?
        resources
      end
    end
  end
end
