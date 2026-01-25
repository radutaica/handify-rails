module Api
  module V1
    class BidsController < BaseController
      before_action :set_task, only: [:create]

      def create
        bid = @task.bids.new(resource_params)
        bid.tasker = current_user

        if bid.save
          Notification.create_bid_received(@task, bid)
          render json: bid, status: :created
        else
          render json: { errors: bid.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def accept
        bid = Bid.find(params[:id])
        authorize_customer!(bid.task)

        if bid.accept!
          Notification.create_task_assigned(bid.task)
          render json: bid, status: :ok
        else
          render json: { errors: bid.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def withdraw
        bid = Bid.find(params[:id])
        authorize_tasker!(bid)

        if bid.withdraw!
          render json: bid, status: :ok
        else
          render json: { errors: bid.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def resource_params
        params.require(:bid).permit(:amount, :estimated_hours, :proposed_date, :proposed_time, :message)
      end

      def set_task
        @task = Task.find(params[:task_id])
      end

      def authorize_customer!(task)
        unless task.customer_id == current_user.id
          render json: { error: 'Unauthorized' }, status: :forbidden
        end
      end

      def authorize_tasker!(bid)
        unless bid.tasker_id == current_user.id
          render json: { error: 'Unauthorized' }, status: :forbidden
        end
      end

      def apply_filters(resources)
        resources = resources.where(task_id: params[:task_id]) if params[:task_id].present?
        resources = resources.where(tasker_id: params[:tasker_id]) if params[:tasker_id].present?
        resources = resources.where(status: params[:status]) if params[:status].present?
        resources
      end
    end
  end
end
