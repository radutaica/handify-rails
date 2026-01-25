module Api
  module V1
    class AuditLogsController < BaseController
      before_action :authorize_admin!

      def index
        logs = AuditLog.all
        logs = apply_filters(logs) if respond_to?(:apply_filters, true)
        logs = apply_pagination(logs)

        render json: logs, status: :ok
      end

      private

      def authorize_admin!
        unless current_user.admin_user&.has_permission?('view_audit_logs')
          render json: { error: 'Unauthorized - Admin access required' }, status: :forbidden
        end
      end

      def apply_filters(resources)
        resources = resources.where(user_id: params[:user_id]) if params[:user_id].present?
        resources = resources.where(action_type: params[:action_type]) if params[:action_type].present?
        resources = resources.where('created_at >= ?', params[:from_date]) if params[:from_date].present?
        resources = resources.where('created_at <= ?', params[:to_date]) if params[:to_date].present?
        resources
      end
    end
  end
end
