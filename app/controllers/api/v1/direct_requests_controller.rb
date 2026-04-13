module Api
  module V1
    class DirectRequestsController < BaseController
      def accept
        request = DirectRequest.find(params[:id])
        authorize_tasker!(request)

        if request.accept!
          render json: request, status: :ok
        else
          render json: { errors: request.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def reject
        request = DirectRequest.find(params[:id])
        authorize_tasker!(request)

        if request.reject!
          render json: request, status: :ok
        else
          render json: { errors: request.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def counter_offer
        request = DirectRequest.find(params[:id])
        authorize_tasker!(request)

        if request.counter_offer!(params[:amount], params[:message])
          render json: request, status: :ok
        else
          render json: { errors: request.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def resource_params
        params.require(:direct_request).permit(
          :tasker_id, :category_id, :address_id, :title, :description,
          :preferred_date, :preferred_time, :estimated_hours, :proposed_amount
        )
      end

      def authorize_tasker!(request)
        unless request.tasker_id == current_user.id
          render json: { error: 'Unauthorized' }, status: :forbidden
        end
      end

      def apply_filters(resources)
        resources = resources.where(tasker_id: params[:tasker_id]) if params[:tasker_id].present?
        resources = resources.where(customer_id: params[:customer_id]) if params[:customer_id].present?
        resources = resources.where(status: params[:status]) if params[:status].present?
        resources
      end
    end
  end
end
