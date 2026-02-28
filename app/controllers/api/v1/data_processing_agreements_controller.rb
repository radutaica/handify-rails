module Api
  module V1
    class DataProcessingAgreementsController < BaseController
      before_action :authorize_dpo!

      private

      def resource_params
        params.require(:data_processing_agreement).permit(
          :processor_name, :processor_type, :dpa_url, :privacy_policy_url,
          :is_active, :signed_at, :expires_at,
          data_transferred: []
        )
      end

      def authorize_dpo!
        unless current_user.admin_user&.dpo? || current_user.admin_user&.super_admin?
          render json: { error: 'Unauthorized - DPO access required' }, status: :forbidden
        end
      end

      def apply_filters(resources)
        resources = resources.where(processor_type: params[:processor_type]) if params[:processor_type].present?
        resources = resources.active if params[:active_only] == 'true'
        resources = resources.expiring_soon if params[:expiring_soon] == 'true'
        resources
      end
    end
  end
end
