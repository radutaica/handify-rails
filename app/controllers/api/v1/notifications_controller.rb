module Api
  module V1
    class NotificationsController < BaseController
      def index
        notifications = current_user.notifications
        notifications = apply_filters(notifications) if respond_to?(:apply_filters, true)
        notifications = apply_pagination(notifications)

        render json: notifications, status: :ok
      end

      def mark_as_read
        notification = current_user.notifications.find(params[:id])

        if notification.mark_as_read!
          render json: notification, status: :ok
        else
          render json: { errors: notification.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def mark_all_as_read
        Notification.mark_all_as_read_for_user(current_user.id)
        head :no_content
      end

      private

      def resource_params
        params.require(:notification).permit(:type, :title, :message, :related_id)
      end

      def apply_filters(resources)
        resources = resources.where(type: params[:type]) if params[:type].present?
        resources = resources.unread if params[:unread_only] == 'true'
        resources
      end
    end
  end
end
