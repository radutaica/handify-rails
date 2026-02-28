module Api
  module V1
    class TasksController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show]

      def index
        resources = resource_class.all
        resources = resources.includes(:category, :address, :customer, :bids, assigned_tasker: :tasker_profile)
        resources = apply_filters(resources) if respond_to?(:apply_filters, true)
        resources = resources.order(created_at: :desc)
        resources = apply_pagination(resources)

        render json: TaskSerializer.serialize_collection(resources), status: :ok
      end

      def show
        task = Task.includes(:category, :address, :customer, :bids, assigned_tasker: :tasker_profile).find(params[:id])
        render json: TaskSerializer.new(task).serializable_hash, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Task not found' }, status: :not_found
      end

      # Override create to set customer_id from current_user
      def create
        task = Task.new(resource_params)
        task.customer = current_user
        task.status ||= 'open'
        task.urgency ||= 'medium'
        task.booking_type ||= 'open_bidding'

        if task.save
          task = Task.includes(:category, :address, :customer, :bids, assigned_tasker: :tasker_profile).find(task.id)
          render json: TaskSerializer.new(task).serializable_hash, status: :created
        else
          render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
        end
      end

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
        resources = resources.where(customer_id: params[:customer_id]) if params[:customer_id].present?
        resources = resources.where(assigned_tasker_id: params[:assigned_tasker_id]) if params[:assigned_tasker_id].present?
        resources = resources.where(urgency: params[:urgency]) if params[:urgency].present?
        resources = resources.where(booking_type: params[:booking_type]) if params[:booking_type].present?

        # Multi-status filter: supports comma-separated values like "open,assigned,in_progress"
        if params[:status].present?
          statuses = params[:status].split(',').map(&:strip)
          resources = resources.where(status: statuses)
        end

        resources
      end
    end
  end
end
