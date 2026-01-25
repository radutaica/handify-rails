module Api
  module V1
    class DisputesController < BaseController
      def resolve
        dispute = Dispute.find(params[:id])
        authorize_admin!

        if dispute.resolve!(current_user, params[:resolution])
          render json: dispute, status: :ok
        else
          render json: { errors: dispute.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def resource_params
        params.require(:dispute).permit(:task_id, :reason)
      end

      def authorize_admin!
        unless current_user.admin_user&.is_active
          render json: { error: 'Unauthorized - Admin access required' }, status: :forbidden
        end
      end

      def apply_filters(resources)
        resources = resources.where(task_id: params[:task_id]) if params[:task_id].present?
        resources = resources.where(status: params[:status]) if params[:status].present?
        resources = resources.open_disputes if params[:open_only] == 'true'
        resources
      end
    end
  end
end
