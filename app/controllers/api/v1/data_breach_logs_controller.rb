module Api
  module V1
    class DataBreachLogsController < BaseController
      before_action :authorize_dpo!

      private

      def resource_params
        params.require(:data_breach_log).permit(
          :breach_type, :severity, :description, :discovered_at,
          :affected_users_count, :mitigation_actions,
          affected_data_types: []
        )
      end

      def authorize_dpo!
        unless current_user.admin_user&.dpo? || current_user.admin_user&.super_admin?
          render json: { error: 'Unauthorized - DPO access required' }, status: :forbidden
        end
      end

      def apply_filters(resources)
        resources = resources.where(severity: params[:severity]) if params[:severity].present?
        resources = resources.where(status: params[:status]) if params[:status].present?
        resources = resources.unresolved if params[:unresolved_only] == 'true'
        resources
      end
    end
  end
end
