module Api
  module V1
    class EncryptionKeysController < BaseController
      before_action :authorize_super_admin!

      private

      def resource_params
        params.require(:encryption_key).permit(
          :key_name, :key_version, :algorithm, :expires_at
        )
      end

      def authorize_super_admin!
        unless current_user.admin_user&.super_admin?
          render json: { error: 'Unauthorized - Super admin access required' }, status: :forbidden
        end
      end

      def apply_filters(resources)
        resources = resources.active if params[:active_only] == 'true'
        resources = resources.expiring_soon if params[:expiring_soon] == 'true'
        resources
      end
    end
  end
end
