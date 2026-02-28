# frozen_string_literal: true

class MessageSerializer
  def initialize(message)
    @message = message
  end

  def serializable_hash
    {
      id: @message.id,
      task_id: @message.task_id,
      direct_request_id: @message.direct_request_id,
      message: @message.message,
      is_read: @message.is_read,
      read_at: @message.read_at,
      attachment_url: @message.attachment_url,
      sender: serialize_user(@message.sender),
      receiver: serialize_user(@message.receiver),
      created_at: @message.created_at,
      updated_at: @message.updated_at
    }
  end

  def self.serialize_collection(messages)
    messages.map { |message| new(message).serializable_hash }
  end

  private

  def serialize_user(user)
    return nil unless user

    {
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      profile_image_url: user.profile_image_url,
      last_active_at: user.last_active_at
    }
  end
end
