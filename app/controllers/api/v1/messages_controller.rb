module Api
  module V1
    class MessagesController < BaseController
      def index
        messages = Message.where('sender_id = ? OR receiver_id = ?', current_user.id, current_user.id)
        messages = apply_filters(messages) if respond_to?(:apply_filters, true)
        messages = apply_pagination(messages)

        render json: messages, status: :ok
      end

      def mark_as_read
        message = Message.find(params[:id])
        authorize_receiver!(message)

        if message.mark_as_read!
          render json: message, status: :ok
        else
          render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def resource_params
        params.require(:message).permit(
          :task_id, :direct_request_id, :receiver_id, :message, :attachment_url
        )
      end

      def authorize_receiver!(message)
        unless message.receiver_id == current_user.id
          render json: { error: 'Unauthorized' }, status: :forbidden
        end
      end

      def apply_filters(resources)
        resources = resources.where(task_id: params[:task_id]) if params[:task_id].present?
        resources = resources.where(direct_request_id: params[:direct_request_id]) if params[:direct_request_id].present?
        resources = resources.unread if params[:unread_only] == 'true'
        resources
      end
    end
  end
end
