module Api
  module V1
    class DataDeletionRequestsController < BaseController
      def index
        if current_user.admin_user&.is_active
          requests = DataDeletionRequest.all
        else
          requests = current_user.data_deletion_requests
        end

        requests = apply_filters(requests) if respond_to?(:apply_filters, true)
        requests = apply_pagination(requests)

        render json: requests, status: :ok
      end

      def create
        request = current_user.data_deletion_requests.new(resource_params)

        if request.save
          render json: request, status: :created
        else
          render json: { errors: request.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def process
        authorize_admin!
        request = DataDeletionRequest.find(params[:id])

        if request.process!(current_user)
          render json: request, status: :ok
        else
          render json: { errors: request.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def complete
        authorize_admin!
        request = DataDeletionRequest.find(params[:id])

        if request.complete!(params[:export_url])
          render json: request, status: :ok
        else
          render json: { errors: request.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def resource_params
        params.require(:data_deletion_request).permit(:request_type, :notes)
      end

      def authorize_admin!
        unless current_user.admin_user&.is_active
          render json: { error: 'Unauthorized - Admin access required' }, status: :forbidden
        end
      end

      def apply_filters(resources)
        resources = resources.where(status: params[:status]) if params[:status].present?
        resources = resources.where(request_type: params[:request_type]) if params[:request_type].present?
        resources
      end
    end
  end
end
