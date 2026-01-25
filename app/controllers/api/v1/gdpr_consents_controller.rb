module Api
  module V1
    class GdprConsentsController < BaseController
      def index
        consents = current_user.gdpr_consents
        render json: consents, status: :ok
      end

      def create
        consent = GdprConsent.record_consent(
          current_user,
          params[:consent_type],
          params[:version],
          request.remote_ip,
          request.user_agent
        )

        if consent.persisted?
          AuditLog.create!(
            user: current_user,
            action_type: 'consent_given',
            ip_address: request.remote_ip,
            user_agent: request.user_agent,
            changes: { consent_type: params[:consent_type], version: params[:version] }
          )
          render json: consent, status: :created
        else
          render json: { errors: consent.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def withdraw
        consent = current_user.gdpr_consents.find(params[:id])

        if consent.withdraw!
          AuditLog.create!(
            user: current_user,
            action_type: 'consent_withdrawn',
            ip_address: request.remote_ip,
            user_agent: request.user_agent,
            changes: { consent_type: consent.consent_type }
          )
          render json: consent, status: :ok
        else
          render json: { errors: consent.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def resource_params
        params.require(:gdpr_consent).permit(:consent_type, :version)
      end
    end
  end
end
