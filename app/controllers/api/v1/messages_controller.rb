module Api
  module V1
    class MessagesController < BaseController
      def index
        messages = Message.where('sender_id = ? OR receiver_id = ?', current_user.id, current_user.id)
                         .includes(:sender, :receiver)
        messages = apply_filters(messages)
        messages = messages.order(created_at: :asc)
        messages = apply_pagination(messages)

        render json: MessageSerializer.serialize_collection(messages), status: :ok
      end

      def show
        message = Message.includes(:sender, :receiver).find(params[:id])
        render json: MessageSerializer.new(message).serializable_hash, status: :ok
      end

      def create
        message = Message.new(resource_params)
        message.sender = current_user

        if message.save
          message.reload
          render json: MessageSerializer.new(message).serializable_hash, status: :created
        else
          render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def conversations
        task_conversations = task_conversation_query
        dr_conversations = direct_request_conversation_query

        all_conversations = (task_conversations + dr_conversations)
          .sort_by { |c| c[:last_message][:created_at] }
          .reverse

        render json: all_conversations, status: :ok
      end

      def mark_as_read
        message = Message.find(params[:id])
        unless message.receiver_id == current_user.id
          render json: { error: 'Unauthorized' }, status: :forbidden and return
        end

        if message.mark_as_read!
          render json: MessageSerializer.new(message.reload).serializable_hash, status: :ok
        else
          render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def mark_all_as_read
        scope = Message.where(receiver_id: current_user.id, is_read: false)
        scope = scope.where(task_id: params[:task_id]) if params[:task_id].present?
        scope = scope.where(direct_request_id: params[:direct_request_id]) if params[:direct_request_id].present?

        marked_count = scope.update_all(is_read: true, read_at: Time.current)
        render json: { marked_count: marked_count }, status: :ok
      end

      private

      def resource_params
        params.require(:message).permit(
          :task_id, :direct_request_id, :receiver_id, :message, :attachment_url
        )
      end

      def apply_filters(resources)
        resources = resources.where(task_id: params[:task_id]) if params[:task_id].present?
        resources = resources.where(direct_request_id: params[:direct_request_id]) if params[:direct_request_id].present?
        resources = resources.unread if params[:unread_only] == 'true'
        resources = resources.where('messages.created_at > ?', params[:created_after]) if params[:created_after].present?
        resources
      end

      def task_conversation_query
        task_ids = Message
          .where('sender_id = ? OR receiver_id = ?', current_user.id, current_user.id)
          .where.not(task_id: nil)
          .select(:task_id)
          .distinct
          .pluck(:task_id)

        task_ids.filter_map do |task_id|
          last_msg = Message.where(task_id: task_id)
                           .where('sender_id = ? OR receiver_id = ?', current_user.id, current_user.id)
                           .includes(:sender, :receiver)
                           .order(created_at: :desc)
                           .first
          next unless last_msg

          task = Task.find_by(id: task_id)
          other_user = last_msg.sender_id == current_user.id ? last_msg.receiver : last_msg.sender
          unread_count = Message.where(task_id: task_id, receiver_id: current_user.id, is_read: false).count

          build_conversation_hash('task', task_id, task&.title, other_user, last_msg, unread_count)
        end
      end

      def direct_request_conversation_query
        dr_ids = Message
          .where('sender_id = ? OR receiver_id = ?', current_user.id, current_user.id)
          .where.not(direct_request_id: nil)
          .select(:direct_request_id)
          .distinct
          .pluck(:direct_request_id)

        dr_ids.filter_map do |dr_id|
          last_msg = Message.where(direct_request_id: dr_id)
                           .where('sender_id = ? OR receiver_id = ?', current_user.id, current_user.id)
                           .includes(:sender, :receiver)
                           .order(created_at: :desc)
                           .first
          next unless last_msg

          direct_request = DirectRequest.find_by(id: dr_id)
          other_user = last_msg.sender_id == current_user.id ? last_msg.receiver : last_msg.sender
          unread_count = Message.where(direct_request_id: dr_id, receiver_id: current_user.id, is_read: false).count

          build_conversation_hash('direct_request', dr_id, direct_request&.title, other_user, last_msg, unread_count)
        end
      end

      def build_conversation_hash(type, context_id, context_title, other_user, last_msg, unread_count)
        {
          id: "#{type}-#{context_id}",
          type: type,
          context_id: context_id,
          context_title: context_title,
          other_user: {
            id: other_user.id,
            first_name: other_user.first_name,
            last_name: other_user.last_name,
            profile_image_url: other_user.profile_image_url,
            last_active_at: other_user.last_active_at
          },
          last_message: {
            message: last_msg.message,
            sender_id: last_msg.sender_id,
            is_read: last_msg.is_read,
            created_at: last_msg.created_at
          },
          unread_count: unread_count
        }
      end
    end
  end
end
